// =================================================================================================
//
//	Starling Framework - Particle System Extension
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package SephiusEngine.displayObjects.particles.system{
	import flash.geom.Rectangle;
	public class Frame{
		public var halfWidth:Number = 1.0;
		public var halfHeight:Number = 1.0;
		
		public var textureX:Number = 0.0;
		public var textureY:Number = 0.0;
		public var textureWidth:Number = 1.0;
		public var textureHeight:Number = 1.0;
		
		public var frameX:Number = 0.0;
		public var frameY:Number = 0.0;
		public var frameWidth:Number = 0.0;
		public var frameHeight:Number = 0.0;
		
		public var width:Number = 1.0;
		public var height:Number = 1.0;
		
		public var useFrame:Boolean = false;
		public var rotated:Boolean = false;
		
		public function Frame(nativeTextureWidth:Number = 64, nativeTextureHeight:Number = 64, x:Number = 0.0, y:Number = 0.0, width:Number = 64.0, height:Number = 64.0, frame:Rectangle = null, rotated:Boolean = false ) {
			textureX = x / nativeTextureWidth;
			textureY = y / nativeTextureHeight;
			textureWidth = (x + width) / nativeTextureWidth;
			textureHeight = (y + height) / nativeTextureHeight;
			
			if(!frame){
				this.halfWidth = width / 2;
				this.halfHeight = height / 2;
			}
			else {
				this.halfWidth = frame.width * .5;
				this.halfHeight = frame.height * .5;
			}
			
			this.width = width;
			this.height = height;
			
			this.rotated = rotated;
			
			this.useFrame = frame;
			if (this.useFrame) {
				this.frameX = frame.x;
				this.frameY = frame.y;
				this.frameWidth = frame.width;
				this.frameHeight = frame.height;
			}
		}
	}
}