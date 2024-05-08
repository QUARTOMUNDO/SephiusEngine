// =================================================================================================
//
//	Starling Framework
//	Copyright 2012 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

// Most of the color transformation math was taken from the excellent ColorMatrix class by
// Mario Klingemann: http://www.quasimondo.com/archives/000565.php -- THANKS!!!

package starling.filters
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Program3D;
	import starling.utils.Color;
    
    import starling.textures.Texture;
    
    /** The ColorMatrixFilter class lets you apply a 4x5 matrix transformation on the RGBA color 
     *  and alpha values of every pixel in the input image to produce a result with a new set 
     *  of RGBA color and alpha values. It allows saturation changes, hue rotation, 
     *  luminance to alpha, and various other effects.
     * 
     *  <p>The class contains several convenience methods for frequently used color 
     *  adjustments. All those methods change the current matrix, which means you can easily 
     *  combine them in one filter:</p>
     *  
     *  <listing>
     *  // create an inverted filter with 50% saturation and 180° hue rotation
     *  var filter:ColorMatrixFilter = new ColorMatrixFilter();
     *  filter.invert();
     *  filter.adjustSaturation(-0.5);
     *  filter.adjustHue(1.0);</listing>
     *  
     *  <p>If you want to gradually animate one of the predefined color adjustments, either reset
     *  the matrix after each step, or use an identical adjustment value for each step; the 
     *  changes will add up.</p>
     */
    public class ColorMatrixFilterWithBlur extends FragmentFilter
    {
        private var mShaderProgram:Program3D;
        
        private var mUserMatrix:Vector.<Number>;   // offset in range 0-255
        private var mShaderMatrix:Vector.<Number>; // offset in range 0-1, changed order
        
        private static const MIN_COLOR:Vector.<Number> = new <Number>[0, 0, 0, 0.0001];
        private static const IDENTITY:Array = [1,0,0,0,0,  0,1,0,0,0,  0,0,1,0,0,  0,0,0,1,0];
        private static const LUMA_R:Number = 0.299;
        private static const LUMA_G:Number = 0.587;
        private static const LUMA_B:Number = 0.114;
        
        /** helper objects */
        private static var sTmpMatrix1:Vector.<Number> = new Vector.<Number>(20, true);
        private static var sTmpMatrix2:Vector.<Number> = new <Number>[];
		
        private const MAX_SIGMA:Number = 2.0;
        
        private var mNormalProgram:Program3D;
        private var mTintedProgram:Program3D;
        
        private var mOffsets:Vector.<Number> = new <Number>[0, 0, 0, 0];
        private var mWeights:Vector.<Number> = new <Number>[0, 0, 0, 0];
        private var mColor:Vector.<Number>   = new <Number>[1, 1, 1, 1];
        
        private var mBlurX:Number;
        private var mBlurY:Number;
        private var mUniformColor:Boolean;
        
        /** helper object */
        private var sTmpWeights:Vector.<Number> = new Vector.<Number>(5, true);
        
        /** Creates a new ColorMatrixFilter instance with the specified matrix. 
         *  @param matrix: a vector of 20 items arranged as a 4x5 matrix.   
         */
        public function ColorMatrixFilterWithBlur(matrix:Vector.<Number>=null, blurX:Number=1, blurY:Number=1, resolution:Number=1)
        {
            mUserMatrix   = new <Number>[];
            mShaderMatrix = new <Number>[];
			
            mBlurX = blurX;
            mBlurY = blurY;
            updateMarginsAndPasses();
			
            this.matrix = matrix;
        }
        
        /** @inheritDoc */
        public override function dispose():void
        {
            if (mNormalProgram) mNormalProgram.dispose();
            if (mShaderProgram) mShaderProgram.dispose();
            super.dispose();
        }
		
		
        /** @private */
        protected override function createPrograms():void
        {
            createProgram();
        }
		
        /** @private */
        protected function createProgram():Program3D
        {
            // vc0-3 - mvp matrix
            // vc4   - kernel offset
            // va0   - position 
            // va1   - texture coords
            
            var vertexProgramCode:String =
                "m44 op, va0, vc0       \n" + // 4x4 matrix transform to output space
                "mov v0, va1            \n" + // pos:  0 |
                "sub v1, va1, vc4.zwxx  \n" + // pos: -2 |
                "sub v2, va1, vc4.xyxx  \n" + // pos: -1 | --> kernel positions
                "add v3, va1, vc4.xyxx  \n" + // pos: +1 |     (only 1st two parts are relevant)
                "add v4, va1, vc4.zwxx  \n";  // pos: +2 |
            
            // v0-v4 - kernel position
            // fs0   - input texture
            // fc0   - weight data
            // fc1   - color (optional)
            // ft0-4 - pixel color from texture
            // ft5   - output color
            
            var fragmentProgramCode:String =
                "tex ft0,  v0, fs0 <2d, clamp, linear, mipnone> \n" +  // read center pixel
                "mul ft5, ft0, fc0.xxxx                         \n" +  // multiply with center weight
                
                "tex ft1,  v1, fs0 <2d, clamp, linear, mipnone> \n" +  // read pixel -2
                "mul ft1, ft1, fc0.zzzz                         \n" +  // multiply with weight
                "add ft5, ft5, ft1                              \n" +  // add to output color
                
                "tex ft2,  v2, fs0 <2d, clamp, linear, mipnone> \n" +  // read pixel -1
                "mul ft2, ft2, fc0.yyyy                         \n" +  // multiply with weight
                "add ft5, ft5, ft2                              \n" +  // add to output color

                "tex ft3,  v3, fs0 <2d, clamp, linear, mipnone> \n" +  // read pixel +1
                "mul ft3, ft3, fc0.yyyy                         \n" +  // multiply with weight
                "add ft5, ft5, ft3                              \n" +  // add to output color

                "tex ft4,  v4, fs0 <2d, clamp, linear, mipnone> \n" +  // read pixel +2
                "mul ft4, ft4, fc0.zzzz                         \n" +   // multiply with weight
                 "add  oc, ft5, ft4                              \n";   // add to output color
				 
            return assembleAgal(fragmentProgramCode, vertexProgramCode);
        }
        
        /** @private */
        protected override function activate(pass:int, context:Context3D, texture:Texture):void
        {
            // already set by super class:
            // 
            // vertex constants 0-3: mvpMatrix (3D)
            // vertex attribute 0:   vertex position (FLOAT_2)
            // vertex attribute 1:   texture coordinates (FLOAT_2)
            // texture 0:            input texture
			
            updateParameters(pass, texture.nativeWidth, texture.nativeHeight);
			
            context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,   4, mOffsets);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, mWeights);
			
            //context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, mShaderMatrix);
            //context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, MIN_COLOR);
			
                context.setProgram(mNormalProgram);
        }
		
        private function updateParameters(pass:int, textureWidth:int, textureHeight:int):void
        {
            // algorithm described here: 
            // http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
            // 
            // To run in constrained mode, we can only make 5 texture lookups in the fragment
            // shader. By making use of linear texture sampling, we can produce similar output
            // to what would be 9 lookups.
            
            var sigma:Number;
            var horizontal:Boolean = pass < mBlurX;
            var pixelSize:Number;
            
            if (horizontal)
            {
                sigma = Math.min(1.0, mBlurX - pass) * MAX_SIGMA;
                pixelSize = 1.0 / textureWidth; 
            }
            else
            {
                sigma = Math.min(1.0, mBlurY - (pass - Math.ceil(mBlurX))) * MAX_SIGMA;
                pixelSize = 1.0 / textureHeight;
            }
            
            const twoSigmaSq:Number = 2 * sigma * sigma; 
            const multiplier:Number = 1.0 / Math.sqrt(twoSigmaSq * Math.PI);
            
            // get weights on the exact pixels (sTmpWeights) and calculate sums (mWeights)
            
            for (var i:int=0; i<5; ++i)
                sTmpWeights[i] = multiplier * Math.exp(-i*i / twoSigmaSq);
            
            mWeights[0] = sTmpWeights[0];
            mWeights[1] = sTmpWeights[1] + sTmpWeights[2]; 
            mWeights[2] = sTmpWeights[3] + sTmpWeights[4];

            // normalize weights so that sum equals "1.0"
            
            var weightSum:Number = mWeights[0] + 2*mWeights[1] + 2*mWeights[2];
            var invWeightSum:Number = 1.0 / weightSum;
            
            mWeights[0] *= invWeightSum;
            mWeights[1] *= invWeightSum;
            mWeights[2] *= invWeightSum;
            
            // calculate intermediate offsets
            
            var offset1:Number = (  pixelSize * sTmpWeights[1] + 2*pixelSize * sTmpWeights[2]) / mWeights[1];
            var offset2:Number = (3*pixelSize * sTmpWeights[3] + 4*pixelSize * sTmpWeights[4]) / mWeights[2];
            
            // depending on pass, we move in x- or y-direction
            
            if (horizontal) 
            {
                mOffsets[0] = offset1;
                mOffsets[1] = 0;
                mOffsets[2] = offset2;
                mOffsets[3] = 0;
            }
            else
            {
                mOffsets[0] = 0;
                mOffsets[1] = offset1;
                mOffsets[2] = 0;
                mOffsets[3] = offset2;
            }
        }
        
        private function updateMarginsAndPasses():void
        {
            if (mBlurX == 0 && mBlurY == 0) mBlurX = 0.001;
            
            numPasses = Math.ceil(mBlurX) + Math.ceil(mBlurY);
            marginX = 4 + Math.ceil(mBlurX);
            marginY = 4 + Math.ceil(mBlurY); 
        }
        
        /** Changes the saturation. Typical values are in the range (-1, 1).
         *  Values above zero will raise, values below zero will reduce the saturation.
         *  '-1' will produce a grayscale image. */ 
        public function adjustSaturation(sat:Number):void
        {
            sat += 1;
            
            var invSat:Number  = 1 - sat;
            var invLumR:Number = invSat * LUMA_R;
            var invLumG:Number = invSat * LUMA_G;
            var invLumB:Number = invSat * LUMA_B;
            
            concatValues((invLumR + sat), invLumG, invLumB, 0, 0,
                         invLumR, (invLumG + sat), invLumB, 0, 0,
                         invLumR, invLumG, (invLumB + sat), 0, 0,
                         0, 0, 0, 1, 0);
        }
        
        /** Changes the contrast. Typical values are in the range (-1, 1).
         *  Values above zero will raise, values below zero will reduce the contrast. */
        public function adjustContrast(value:Number):void
        {
            var s:Number = value + 1;
            var o:Number = 128 * (1 - s);
            
            concatValues(s, 0, 0, 0, o,
                         0, s, 0, 0, o,
                         0, 0, s, 0, o,
                         0, 0, 0, 1, 0);
        }
        
        /** Changes the brightness. Typical values are in the range (-1, 1).
         *  Values above zero will make the image brighter, values below zero will make it darker.*/ 
        public function adjustBrightness(value:Number):void
        {
            value *= 255;
            
            concatValues(1, 0, 0, 0, value,
                         0, 1, 0, 0, value,
                         0, 0, 1, 0, value,
                         0, 0, 0, 1, 0);
        }
        
        /** Changes the hue of the image. Typical values are in the range (-1, 1). */
        public function adjustHue(value:Number):void
        {
            value *= Math.PI;
            
            var cos:Number = Math.cos(value);
            var sin:Number = Math.sin(value);
            
            concatValues(
                ((LUMA_R + (cos * (1 - LUMA_R))) + (sin * -(LUMA_R))), ((LUMA_G + (cos * -(LUMA_G))) + (sin * -(LUMA_G))), ((LUMA_B + (cos * -(LUMA_B))) + (sin * (1 - LUMA_B))), 0, 0,
                ((LUMA_R + (cos * -(LUMA_R))) + (sin * 0.143)), ((LUMA_G + (cos * (1 - LUMA_G))) + (sin * 0.14)), ((LUMA_B + (cos * -(LUMA_B))) + (sin * -0.283)), 0, 0,
                ((LUMA_R + (cos * -(LUMA_R))) + (sin * -((1 - LUMA_R)))), ((LUMA_G + (cos * -(LUMA_G))) + (sin * LUMA_G)), ((LUMA_B + (cos * (1 - LUMA_B))) + (sin * LUMA_B)), 0, 0,
                0, 0, 0, 1, 0);
        }
        
        // matrix manipulation
        
        /** Changes the filter matrix back to the identity matrix. */
        public function reset():void
        {
            matrix = null;
        }
        
        /** Concatenates the current matrix with another one. */
        public function concat(matrix:Vector.<Number>):void
        {
            var i:int = 0;

            for (var y:int=0; y<4; ++y)
            {
                for (var x:int=0; x<5; ++x)
                {
                    sTmpMatrix1[int(i+x)] = 
                        matrix[i]        * mUserMatrix[x]           +
                        matrix[int(i+1)] * mUserMatrix[int(x +  5)] +
                        matrix[int(i+2)] * mUserMatrix[int(x + 10)] +
                        matrix[int(i+3)] * mUserMatrix[int(x + 15)] +
                        (x == 4 ? matrix[int(i+4)] : 0);
                }
                
                i+=5;
            }
            
            copyMatrix(sTmpMatrix1, mUserMatrix);
            updateShaderMatrix();
        }
        
        /** Concatenates the current matrix with another one, passing its contents directly. */
        private function concatValues(m0:Number, m1:Number, m2:Number, m3:Number, m4:Number, 
                                      m5:Number, m6:Number, m7:Number, m8:Number, m9:Number, 
                                      m10:Number, m11:Number, m12:Number, m13:Number, m14:Number, 
                                      m15:Number, m16:Number, m17:Number, m18:Number, m19:Number
                                      ):void
        {
            sTmpMatrix2.length = 0;
            sTmpMatrix2.push(m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, 
                m10, m11, m12, m13, m14, m15, m16, m17, m18, m19);
            
            concat(sTmpMatrix2);
        }

        private function copyMatrix(from:Vector.<Number>, to:Vector.<Number>):void
        {
            for (var i:int=0; i<20; ++i)
                to[i] = from[i];
        }
        
        private function updateShaderMatrix():void
        {
            // the shader needs the matrix components in a different order, 
            // and it needs the offsets in the range 0-1.
            
            mShaderMatrix.length = 0;
            mShaderMatrix.push(
                mUserMatrix[0],  mUserMatrix[1],  mUserMatrix[2],  mUserMatrix[3],
                mUserMatrix[5],  mUserMatrix[6],  mUserMatrix[7],  mUserMatrix[8],
                mUserMatrix[10], mUserMatrix[11], mUserMatrix[12], mUserMatrix[13], 
                mUserMatrix[15], mUserMatrix[16], mUserMatrix[17], mUserMatrix[18],
                mUserMatrix[4] / 255.0,  mUserMatrix[9] / 255.0,  mUserMatrix[14] / 255.0,  
                mUserMatrix[19] / 255.0
            );
        }
        
        // properties
        
        /** A vector of 20 items arranged as a 4x5 matrix. */
        public function get matrix():Vector.<Number> { return mUserMatrix; }
        public function set matrix(value:Vector.<Number>):void
        {
            if (value && value.length != 20) 
                throw new ArgumentError("Invalid matrix length: must be 20");
            
            if (value == null)
            {
                mUserMatrix.length = 0;
                mUserMatrix.push.apply(mUserMatrix, IDENTITY);
            }
            else
            {
                copyMatrix(value, mUserMatrix);
            }
            
            updateShaderMatrix();
        }
		
        /** The blur factor in x-direction (stage coordinates). 
         *  The number of required passes will be <code>Math.ceil(value)</code>. */
        public function get blurX():Number { return mBlurX; }
        public function set blurX(value:Number):void 
        { 
            mBlurX = value; 
            updateMarginsAndPasses(); 
        }
        
        /** The blur factor in y-direction (stage coordinates). 
         *  The number of required passes will be <code>Math.ceil(value)</code>. */
        public function get blurY():Number { return mBlurY; }
        public function set blurY(value:Number):void 
        { 
            mBlurY = value; 
            updateMarginsAndPasses(); 
        }
    }
}