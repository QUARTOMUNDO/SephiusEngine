package SephiusEngine.displayObjects.particles.system {
	import SephiusEngine.displayObjects.particles.ParticleSystemEX;
	import flash.geom.Rectangle;
	import org.osflash.signals.Signal;
	import nape.geom.Vec2;
	
	/**
	 * Object ParticleSystemEx uses to emit particles
	 * @author Fernando Rabello
	 */
	public class ParticleEmitter {
		
		public function ParticleEmitter() { }
		
		public function destroy():void {
			var particleSystem:ParticleSystemEX;
			for each (particleSystem in systemsAssigned) {
				particleSystem.unassignEmitter(this);
			}
			
			onDestroyed.dispatch(this);
			onDestroyed.removeAll();
			onDepleted.removeAll();
		}
		
		/** List the systems this emitter is assinged to */
		public var systemsAssigned:Vector.<ParticleSystemEX> = new Vector.<ParticleSystemEX>();
		
		/** Time witch determine for how much time emitter should emit */
		public var emissionTime:Number = Number.MAX_VALUE;
		
		/** If true, system will ignore emitter emission rate and use its own */
		public var useSystemEmissionRate:Boolean = false;
		
		/** The amount of particles emited per second */
		public var emissionRate:Number = 200;
		
		/** Time where emitter is emiting particles on a certain frame. Used internally, do not change! */
		public var frameTime:Number = 0;
		
		/** Number of particles from this emitter */
		public var numParticles							:int = 0;
		
		/** The position of the emitter on X axis */
		public var emitterX								:Number = 0;
		/** The position of the emitter on Y axis */
		public var emitterY								:Number = 0;
		
		/** Rotation of the emitter in radians */
		public var emitterRotation						:Number = 0;
		
		/** Displace the partice spawn from the emitterX */
		public var emitterOffsetX						:Number = 0;
		/** Displace the partice spawn from the emitterY */
		public var emitterOffsetY						:Number = 0;
		
		/** Scarter particles spawn on X axis */
		public var emitterXVariance						:Number = 0;
		/** Scarter particles spawn on Y axis */
		public var emitterYVariance						:Number = 0;
		
		/** Makes particles spawn away from emiter in the direction of the emiterAngle */
		public var emitterRadius						:Number = 0;
		/** Variation on emitter radius. Makes particles spawn like a band and not like a line arround emitter */
		public var emitterRadiusVariance				:Number = 0;
		
		/** The angle witch particle will spawn and directed to */
		public var emissionAngle						:Number = 0;
		/** Makes particles spawn arround the emiter */
		public var emissionAngleVariance				:Number = 360;
		
		/** The velocity of the emitter. Its grants particles more velocity if system inheritVelocyX is above 0*/
		public var emitterVelocityX						:Number = 0;
		/** The velocity of the emitter. Its grants particles more velocity if system inheritVelocyY is above 0*/
		public var emitterVelocityY						:Number = 0;
		
		/** Actual number of particle created by this emitter alone. */
		public var finalCount							:int = 0;
		/** Final number of particles that can be created. -1 for infinite. If final count is archeved emitter will no longer create particles */
		public var finalAmount							:int = 0;
		
		/** Define the area witch partiles will get deleted if they go beyond. If null particles will be boundless.*/
		public var areaRect:Rectangle;
		
		/** If true emitter should not emit particles anymore */
		public var depleted:Boolean;
		
		/** If true emitter should not emit particles anymore */
		public var finished:Boolean;
		
		/** Dispach a signal when final amount is equal to final count */
		public var onDepleted							:Signal = new Signal(ParticleEmitter);
		/** Dispatch a event when emitter is destroyed */
		public var onDestroyed							:Signal = new Signal(ParticleEmitter);
		/** Dispatch a event when emitter is destroyed */
		public var onFinished							:Signal = new Signal(ParticleEmitter);
	}
}