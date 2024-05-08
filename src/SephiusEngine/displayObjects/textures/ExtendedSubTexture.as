package SephiusEngine.displayObjects.textures
{
	import SephiusEngine.utils.pools.RectanglePool;

	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import starling.textures.ConcreteTexture;
	import starling.textures.Texture;
	import starling.utils.VertexData;

    /** Alow create this sub texture without a parent texture. So its possible have the subtexture before loading the concrete texture data.
	 * This also has some hacks to save performance. Some times system need to create thousands of subtextures at 1 frame.
	 * A SubTexture represents a section of another texture. This is achieved solely by 
     *  manipulation of texture coordinates, making the class very efficient. 
     *
     *  <p><em>Note that it is OK to create subtextures of subtextures.</em></p>
     */ 
    public class ExtendedSubTexture extends Texture
    {
        private var mParent:Texture;
        private var mOwnsParent:Boolean;
        private var mFrame:Rectangle;
        private var mRotated:Boolean;
        private var mWidth:Number;
        private var mHeight:Number;
        private var mTransformationMatrix:Matrix;

		private var mRootClipping:Rectangle;

        /** Helper objects. */
        private static var sTexCoords:Point = new Point();
        private static var parentTextureH:ExtendedSubTexture;
        private static var textureH:ExtendedSubTexture;
		private static var parentClippingH:Rectangle;
 		private static var clipXH:Number;	
		private static var clipYH:Number;	
		private static var clipWidthH:Number; 		
		private static var clipHeightH:Number;		
		private static var endIndexH:int;
		private static var endIndex2H:int;

        
        /** Creates a new subtexture containing the specified region (in points) of a parent 
         *  texture. If 'ownsParent' is true, the parent texture will be disposed automatically
         *  when the subtexture is disposed. */
        public function ExtendedSubTexture(parentTexture:Texture, region:Rectangle,
                                   ownsParent:Boolean=false, frame:Rectangle=null, parentWidth:Number = 1, parentHeight:Number = 1, rotated:Boolean=false)
        {
			mParent = parentTexture;
            mOwnsParent = ownsParent;
			mFrame = frame;
			mRotated = rotated;
			
            mWidth  = rotated ? region.height : region.width;
            mHeight = rotated ? region.width  : region.height;
            mTransformationMatrix = new Matrix();
            
            if (rotated)
            {
                mTransformationMatrix.translate(0, -1);
                mTransformationMatrix.rotate(Math.PI / 2.0);
            }
			
            mTransformationMatrix.scale(region.width  / mParent.width,
                                        region.height / mParent.height);
            mTransformationMatrix.translate(region.x / mParent.width,
                                            region.y / mParent.height);
        }
        
        /** Disposes the parent texture if this texture owns it. */
        public override function dispose():void
        {mClipping
			RectanglePool.returnRectangle(mClipping);
			RectanglePool.returnRectangle(mRootClipping);
			
            if (mOwnsParent) mParent.dispose();
            super.dispose();
        }
        
        private function setClipping(value:Rectangle):void
        {
            mClipping = value;
            mRootClipping = value.clone();
            
            parentTextureH = mParent as ExtendedSubTexture;
            while (parentTextureH)
            {
                parentClippingH = parentTextureH.mClipping;
                mRootClipping.x = parentClippingH.x + mRootClipping.x * parentClippingH.width;
                mRootClipping.y = parentClippingH.y + mRootClipping.y * parentClippingH.height;
                mRootClipping.width  *= parentClippingH.width;
                mRootClipping.height *= parentClippingH.height;
                parentTextureH = parentTextureH.mParent as ExtendedSubTexture;
            }
        }
        
        /** @inheritDoc */
        public override function adjustVertexData(vertexData:VertexData, vertexID:int, count:int):void
        {
            super.adjustVertexData(vertexData, vertexID, count);
			
			endIndexH = vertexID + count;
            for (endIndex2H=vertexID; endIndex2H<endIndexH; ++endIndex2H)
            {
                vertexData.getTexCoords(endIndex2H, sTexCoords);
                vertexData.setTexCoords(endIndex2H, mRootClipping.x + sTexCoords.x * mRootClipping.width,
                                           mRootClipping.y + sTexCoords.y * mRootClipping.height);
            }
        }

        /** @inheritDoc */
        public override function adjustTexCoords(texCoords:Vector.<Number>,
                                                 startIndex:int=0, stride:int=0, count:int=-1):void
        {
            if (count < 0)
                count = (texCoords.length - startIndex - 2) / (stride + 2) + 1;
            
            endIndexH = startIndex;
            for (endIndex2H=0; endIndex2H<count; ++endIndex2H)
            {
                texCoords[endIndexH] = mRootClipping.x + texCoords[endIndexH] * mRootClipping.width;
                endIndexH += 1;
                texCoords[endIndexH] = mRootClipping.y + texCoords[endIndexH] * mRootClipping.height;
                endIndexH += 1 + stride;
            }
        }
				
        /** The texture which the subtexture is based on. */ 
        public function get parent():Texture { return mParent; }
        
        /** Indicates if the parent texture is disposed when this object is disposed. */
        public function get ownsParent():Boolean { return mOwnsParent; }
        
        /** The clipping rectangle, which is the region provided on initialization 
         *  scaled into [0.0, 1.0]. */
        public function get clipping():Rectangle { return mClipping.clone(); }
        private var mClipping:Rectangle;

        /** @inheritDoc */
        public override function get base():TextureBase { return mParent.base; }
        
        /** @inheritDoc */
        public override function get root():ConcreteTexture { return mParent.root; }
        
        /** @inheritDoc */
        public override function get format():String { return mParent.format; }
        
        /** @inheritDoc */
        public override function get width():Number { return mParent.width * mClipping.width; }
        
        /** @inheritDoc */
        public override function get height():Number { return mParent.height * mClipping.height; }
        
        /** @inheritDoc */
        public override function get nativeWidth():Number { return mParent.nativeWidth * mClipping.width; }
        
        /** @inheritDoc */
        public override function get nativeHeight():Number { return mParent.nativeHeight * mClipping.height; }
        
        /** @inheritDoc */
        public override function get mipMapping():Boolean { return mParent.mipMapping; }
        
        /** @inheritDoc */
        public override function get premultipliedAlpha():Boolean { return mParent.premultipliedAlpha; }
        
        /** @inheritDoc */
        public override function get scale():Number { return mParent.scale; } 
        
    }
}