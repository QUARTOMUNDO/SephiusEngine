// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package SephiusEngine.utils
{
    import starling.errors.AbstractClassError;

    /** A utility class containing predefined colors and methods converting between different
     *  color representations. 
	 *  Modified verson from Starling Color Class. Custom colors and other methods.
	 * */
    public class ColorsUtils
    {
		public static const DAMAGED:uint 				= 0xffbb77;
		public static const DAMAGE_INVUNERABLE:uint 	= 0xffbb77;
		public static const SHIELD_DAMAGED:uint 		= 0xffffff;
		public static const FROZEN:uint 				= 0x51bfff;
		public static const BURNING:uint 				= 0xeecc66;
		public static const ILLUMINATED:uint 			= 0xffee99;
		public static const NIGRICANED:uint 			= 0x444444;
		public static const INTOXICATED:uint 			= 0x55ff51;
		public static const PHYSICAL_IMPAIRED:uint 		= 0xadbeac;
		public static const MYSTICAL_IMPAIRMENT:uint 	= 0xacb6be;
		public static const AMPLIFIED:uint 				= 0xfff2c0;
		public static const PHYSICALLY_PROTECTED:uint 	= 0xeee4be;
		public static const MYSTICALLY_PROTECTED:uint 	= 0xbee4ee;
		public static const WARMLY_PROTECTED:uint 		= 0xffb80e;
		public static const COLDLY_PROTECTED:uint 		= 0xd7edff;
		public static const DEMYSTIFIED:uint 			= 0x874141;
		public static const MYSTIFIED:uint 				= 0xff7d7d;
		public static const PETRIFIED:uint 				= 0x716f4c;
		public static const DISPELL:uint				= 0x8ffff8;
		public static const SPECIALIZED:uint 			= 0xfeff9f;
		public static const UNBEATABLE:uint 			= 0x99ddff;
		
        public static const WHITE:uint   = 0xffffff;
        public static const SILVER:uint  = 0xc0c0c0;
        public static const GRAY:uint    = 0x808080;
        public static const BLACK:uint   = 0x000000;
        public static const RED:uint     = 0xff0000;
        public static const MAROON:uint  = 0x800000;
        public static const YELLOW:uint  = 0xffff00;
        public static const OLIVE:uint   = 0x808000;
        public static const LIME:uint    = 0x00ff00;
        public static const GREEN:uint   = 0x008000;
        public static const AQUA:uint    = 0x00ffff;
        public static const TEAL:uint    = 0x008080;
        public static const BLUE:uint    = 0x0000ff;
        public static const NAVY:uint    = 0x000080;
        public static const FUCHSIA:uint = 0xff00ff;
        public static const PURPLE:uint  = 0x800080;
        
        public static const LIGHT:uint   	= 0xFFFFFF;
		public static const DARK:uint    	= 0xff0000;
		public static const BIO:uint 	 	= 0x800080;
	    public static const CORRUPTION:uint = 0x008000;
		public static const EARTH:uint  	= 0x71470F;
		public static const FIRE:uint  		= 0xF98835;
		public static const ICE:uint    	= 0x66E4FF;
		public static const WATER:uint    	= 0x007AF4;
		public static const AIR:uint    	= 0xc0c0c0;
		public static const PSIONICA:uint   = 0xF5FF79;
		
        
        /** Returns the alpha part of an ARGB color (0 - 255). */
        public static function getAlpha(color:uint):int { return (color >> 24) & 0xff; }
        
        /** Returns the red part of an (A)RGB color (0 - 255). */
        public static function getRed(color:uint):int   { return (color >> 16) & 0xff; }
        
        /** Returns the green part of an (A)RGB color (0 - 255). */
        public static function getGreen(color:uint):int { return (color >>  8) & 0xff; }
        
        /** Returns the blue part of an (A)RGB color (0 - 255). */
        public static function getBlue(color:uint):int  { return  color        & 0xff; }
        
        /** Creates an RGB color, stored in an unsigned integer. Channels are expected
         *  in the range 0 - 255. */
        public static function rgb(red:int, green:int, blue:int):uint
        {
            return (red << 16) | (green << 8) | blue;
        }
        
        /** Creates an ARGB color, stored in an unsigned integer. Channels are expected
         *  in the range 0 - 255. */
        public static function argb(alpha:int, red:int, green:int, blue:int):uint
        {
            return (alpha << 24) | (red << 16) | (green << 8) | blue;
        }
		
		/**  RGB figures show (0x000000 0xFFFFFF up from) the
		 * R, G, B returns an array divided into a number from 0 to 255, respectively.
		 * @ Param rgb RGB numbers show (0x000000 0xFFFFFF up from)
		 * @ Return array indicates the value of each color [R, G, B]
		 **/
		public static function toRGB (rgb: uint): Array
		{
			var r: uint = rgb>> 16 & 0xFF;
			var g: uint = rgb>> 8 & 0xFF;
			var b: uint = rgb & 0xFF;
			return [r, g, b];
		}
		
 
		/**
		 * Subtraction.  
		 * 2 RGB single number that indicates (0x000000 0xFFFFFF up from) is subtracted 
         * from the return numbers.
		 * @ Param col1 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @ Param col2 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @ Return value subtracted Blend 
		 **/
		public static function subtract (col1: uint, col2: uint): uint
		{
			var colA: Array = toRGB (col1);
			var colB: Array = toRGB (col2);
			var r: uint = Math.max (Math.max (colB [0] - (256-colA [0]), 
                                                                colA [0] - (256-colB [0])), 0);
			var g: uint = Math.max (Math.max (colB [1] - (256-colA [1]), 
                                                                colA [1] - (256-colB [1])), 0);
			var b: uint = Math.max (Math.max (colB [2] - (256-colA [2]), 
                                                                colA [2] - (256-colB [2])), 0);
			return r <<16 | g <<8 | b;
		}
 
		/**
		 * Additive color. 
		 * 2 RGB single number that indicates (0x000000 0xFFFFFF up from) Returns the value 
                 * of the additive mixture.
		 * @ Param col1 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @ Param col2 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @ Return the additive color
		 **/
		public static function sum (col1: uint, col2: uint): uint
		{
			var c1: Array = toRGB (col1);
			var c2: Array = toRGB (col2);
			var r: uint = Math.min (c1 [0] + c2 [0], 255);
			var g: uint = Math.min (c1 [1] + c2 [1], 255);
			var b: uint = Math.min (c1 [2] + c2 [2], 255);
			return r <<16 | g <<8 | b;
		}
 
		/**
		 * Subtractive. 
		 * 2 RGB single number that indicates (0x000000 0xFFFFFF up from) Returns the value 
         * of the subtractive color.
		 * @ Param col1 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @ Param col2 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @ Return the subtractive
		 **/
		public static function sub (col1: uint, col2: uint): uint
		{
			var c1: Array = toRGB (col1);
			var c2: Array = toRGB (col2);
			var r: uint = Math.max (c1 [0]-c2 [0], 0);
			var g: uint = Math.max (c1 [1]-c2 [1], 0);
			var b: uint = Math.max (c1 [2]-c2 [2], 0);
			return r <<16 | g <<8 | b;
		}
 
		/**
		 * Comparison (dark). 
		 * 2 RGB single number that indicates (0x000000 0xFFFFFF up from) to compare,
                 * RGB lower combined returns a numeric value for each number.
		 * @ Param col1 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @ Param col2 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @ Return comparison (dark) values
		 **/
		public static function min (col1: uint, col2: uint): uint
		{
			var c1: Array = toRGB (col1);
			var c2: Array = toRGB (col2);
			var r: uint = Math.min (c1 [0], c2 [0]);
			var g: uint = Math.min (c1 [1], c2 [1]);
			var b: uint = Math.min (c1 [2], c2 [2]);
			return r <<16 | g <<8 | b;
		}
 
		/**
		 * Comparison (light). 
		 * 2 RGB single number that indicates (0x000000 0xFFFFFF up from) to compare, 
                 * RGB values combined with higher returns to their numbers.
		 * @ Param col1 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @ Param col2 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @ Return comparison (light) value
		 **/
		public static function max (col1: uint, col2: uint): uint
		{
			var c1: Array = toRGB (col1);
			var c2: Array = toRGB (col2);
			var r: uint = Math.max (c1 [0], c2 [0]);
			var g: uint = Math.max (c1 [1], c2 [1]);
			var b: uint = Math.max (c1 [2], c2 [2]);
			return r <<16 | g <<8 | b;
		}
		
        /** @private */
        public function ColorsUtils() { throw new AbstractClassError(); }
    }
}