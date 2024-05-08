// =================================================================================================
//
//        Starling Framework
//        Copyright 2012 Gamua OG. All Rights Reserved.
//
//        This program is free software. You can redistribute and/or modify it
//        in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.filters
{
	import flash.display.Stage3D;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.errors.IllegalOperationError;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import flash.system.Capabilities;
    import flash.utils.getQualifiedClassName;
    
    import starling.core.RenderSupport;
    import starling.core.Starling;
    import starling.core.starling_internal;
    import starling.display.BlendMode;
    import starling.display.DisplayObject;
    import starling.display.Image;
    import starling.display.QuadBatch;
    import starling.display.Stage;
    import starling.errors.AbstractClassError;
    import starling.errors.MissingContextError;
    import starling.events.Event;
    import starling.textures.Texture;
    import starling.utils.MatrixUtil;
    import starling.utils.RectangleUtil;
    import starling.utils.VertexData;
    import starling.utils.getNextPowerOfTwo;

    /** The FragmentFilter class is the base class for all filter effects in Starling.
     *  All other filters of this package extend this class. You can attach them to any display
     *  object through the 'filter' property.
     * 
     *  <p>A fragment filter works in the following way:</p>
     *  <ol>
     *    <li>The object that is filtered is rendered into a texture (in stage coordinates).</li>
     *    <li>That texture is passed to the first filter pass.</li>
     *    <li>Each pass processes the texture using a fragment shader (and optionally a vertex 
     *        shader) to achieve a certain effect.</li>
     *    <li>The output of each pass is used as the input for the next pass; if it's the 
     *        final pass, it will be rendered directly to the back buffer.</li>  
     *  </ol>
     * 
     *  <p>All of this is set up by the abstract FragmentFilter class. Concrete subclasses
     *  just need to override the protected methods 'createPrograms', 'activate' and 
     *  (optionally) 'deactivate' to create and execute its custom shader code. Each filter
     *  can be configured to either replace the original object, or be drawn below or above it.
     *  This can be done through the 'mode' property, which accepts one of the Strings defined
     *  in the 'FragmentFilterMode' class.</p>
     * 
     *  <p>Beware that each filter should be used only on one object at a time. Otherwise, it
     *  will get slower and require more resources; and caching will lead to undefined
     *  results.</p>
     */ 
    public class FragmentFilterFullScreen extends FragmentFilter
    {
        /** Creates a new Fragment filter with the specified number of passes and resolution.
         *  This constructor may only be called by the constructor of a subclass. */
        public function FragmentFilterFullScreen(numPasses:int=1, resolution:Number=1.0)
        {
			super(numPasses, resolution);
        }
		/*
        override protected function renderPasses(object:DisplayObject, support:RenderSupport, 
                                      parentAlpha:Number, intoCache:Boolean=false):QuadBatch
        {
            var passTexture:Texture;
            var cacheTexture:Texture = null;
            var stage:Stage = object.stage;
            var context:Context3D = Starling.context;
            var scale:Number = Starling.current.contentScaleFactor;
            
            if (stage   == null) throw new Error("Filtered object must be on the stage.");
            if (context == null) throw new MissingContextError();
            
            // the bounds of the object in stage coordinates 
            calculateBounds(object, stage, mResolution * scale, !intoCache, sBounds, sBoundsPot);
            
            if (sBounds.isEmpty())
            {
                disposePassTextures();
                return intoCache ? new QuadBatch() : null; 
            }
            
            updateBuffers(context, sBoundsPot);
            updatePassTextures(sBoundsPot.width, sBoundsPot.height, mResolution * scale);
            
            support.finishQuadBatch();
            support.raiseDrawCount(mNumPasses);
            support.pushMatrix();
            
            // save original projection matrix and render target
            mProjMatrix.copyFrom(support.projectionMatrix); 
            var previousRenderTarget:Texture = support.renderTarget;

            if (intoCache) 
                cacheTexture = Texture.empty(sBoundsPot.width, sBoundsPot.height, PMA, false, true, 
                                             mResolution * scale, Context3DTextureFormat.BGRA );
            
            // draw the original object into a texture
            support.renderTarget = mPassTextures[0];
            support.clear();
            support.blendMode = mBlendMode;
            support.setOrthographicProjection(sBounds.x, sBounds.y, sBoundsPot.width, sBoundsPot.height);
            object.render(support, parentAlpha);
            support.finishQuadBatch();
            
            // prepare drawing of actual filter passes
            RenderSupport.setBlendFactors(PMA);
            support.loadIdentity();  // now we'll draw in stage coordinates!
            support.pushClipRect(sBounds);
            
            context.setVertexBufferAt(mVertexPosAtID, mVertexBuffer, VertexData.POSITION_OFFSET, 
                                      Context3DVertexBufferFormat.FLOAT_2);
            context.setVertexBufferAt(mTexCoordsAtID, mVertexBuffer, VertexData.TEXCOORD_OFFSET,
                                      Context3DVertexBufferFormat.FLOAT_2);
            
            // draw all passes
            for (var i:int=0; i<mNumPasses; ++i)
            {
                if (i < mNumPasses - 1) // intermediate pass  
                {
                    // draw into pass texture
                    support.renderTarget = getPassTexture(i+1);
                    support.clear();
                }
                else // final pass
                {
                    if (intoCache || previousRenderTarget)
                    {
                        // draw into cache texture
                        support.renderTarget = cacheTexture ? cacheTexture: previousRenderTarget;
                        support.clear();
                    }
                    else
                    {
                        // draw into back buffer, at original (stage) coordinates
                        support.projectionMatrix = mProjMatrix;
                        support.renderTarget = null;
                        support.translateMatrix(mOffsetX, mOffsetY);
                        support.blendMode = object.blendMode;
                        support.applyBlendMode(PMA);
                    }
                }
                
                passTexture = getPassTexture(i);
                context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, mMvpConstantID, 
                                                      support.mvpMatrix3D, true);
                context.setTextureAt(mBaseTextureID, passTexture.base);
                
                activate(i, context, passTexture);
                context.drawTriangles(mIndexBuffer, 0, 2);
                deactivate(i, context, passTexture);
            }
            
            // reset shader attributes
            context.setVertexBufferAt(mVertexPosAtID, null);
            context.setVertexBufferAt(mTexCoordsAtID, null);
            context.setTextureAt(mBaseTextureID, null);
            
            support.popMatrix();
            support.popClipRect();
            
            if (intoCache)
            {
                // restore support settings
                support.renderTarget = previousRenderTarget;
                support.projectionMatrix.copyFrom(mProjMatrix);
                
                // Create an image containing the cache. To have a display object that contains
                // the filter output in object coordinates, we wrap it in a QuadBatch: that way,
                // we can modify it with a transformation matrix.
                
                var quadBatch:QuadBatch = new QuadBatch();
                var image:Image = new Image(cacheTexture);
                
                stage.getTransformationMatrix(object, sTransformationMatrix);
                MatrixUtil.prependTranslation(sTransformationMatrix, 
                                              sBounds.x + mOffsetX, sBounds.y + mOffsetY);
                quadBatch.addImage(image, 1.0, sTransformationMatrix);

                return quadBatch;
            }
            else return null;
        }
		
        override protected function updatePassTextures(width:int, height:int, scale:Number):void
        {
            var numPassTextures:int = mNumPasses > 1 ? 2 : 1;
            var needsUpdate:Boolean = mPassTextures == null || 
                mPassTextures.length != numPassTextures ||
                mPassTextures[0].width != width || mPassTextures[0].height != height;  
            
            if (needsUpdate)
            {
                if (mPassTextures)
                {
                    for each (var texture:Texture in mPassTextures) 
                        texture.dispose();
                    
                    mPassTextures.length = numPassTextures;
                }
                else
                {
                    mPassTextures = new Vector.<Texture>(numPassTextures);
                }
                
                for (var i:int=0; i<numPassTextures; ++i)
                    mPassTextures[i] = Texture.empty(width, height, PMA, false, true, scale, Context3DTextureFormat.BGRA);
            }
        }*/
		
        /** Calculates the bounds of the filter in stage coordinates. The method calculates two
         *  rectangles: one with the exact filter bounds, the other with an extended rectangle that
         *  will yield to a POT size when multiplied with the current scale factor / resolution.
         *//*
        override protected function calculateBounds(object:DisplayObject, targetSpace:DisplayObject,
                                         scale:Number, intersectWithStage:Boolean,
                                         resultRect:Rectangle,
                                         resultPotRect:Rectangle):void
        {
            var marginX:Number, marginY:Number;
            
            // optimize for full-screen effects
            marginX = marginY = 0;
            resultRect.setTo(0, 0, stage.stageWidth, stage.stageHeight);
			
            if (intersectWithStage)
            {
                sStageBounds.setTo(0, 0, stage.stageWidth, stage.stageHeight);
                RectangleUtil.intersect(resultRect, sStageBounds, resultRect);
            }
			
            if (!resultRect.isEmpty())
            {    
                // the bounds are a rectangle around the object, in stage coordinates,
                // and with an optional margin. 
                //resultRect.inflate(marginX, marginY);
                
                // To fit into a POT-texture, we extend it towards the right and bottom.
                var minSize:int = MIN_TEXTURE_SIZE / scale;
                var minWidth:Number  = resultRect.width  > minSize ? resultRect.width  : minSize;
                var minHeight:Number = resultRect.height > minSize ? resultRect.height : minSize;
                resultPotRect.setTo(
                    resultRect.x, resultRect.y,
                    getNextPowerOfTwo(minWidth  * scale) / scale,
                    getNextPowerOfTwo(minHeight * scale) / scale);
            }
			
        }*/
    }
}