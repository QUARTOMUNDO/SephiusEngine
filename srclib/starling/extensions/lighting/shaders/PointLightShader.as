package starling.extensions.lighting.shaders
{

	import starling.extensions.lighting.lights.PointLight;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	/**
	 * @author Szenia Zadvornykh
	 * 
	 * original shader by Ryan Speets @ ryanspeets.com
	 */
	public class PointLightShader extends StarlingShaderBase
	{
		private const NAME:String = "PointLightShader";
		
		private var params:Vector.<Number>;
		private var _vertexBuffer:VertexBuffer3D;
		private var _uvBuffer:VertexBuffer3D;
		
		public function PointLightShader(width:int, height:int)
		{
			super(NAME);
			
			params = new Vector.<Number>(12);
			
			params[2] = width;
			params[3] = height;
			params[4] = 0;
			params[5] = 1;
			params[6] = 0;
			params[11] = 1;
		}
		
		public function setDependencies(vertexBuffer:VertexBuffer3D, uvBuffer:VertexBuffer3D):void
		{
			_vertexBuffer = vertexBuffer;
			_uvBuffer = uvBuffer;
		}
		
		public function set light(light:PointLight):void
		{
			params[0] = light.x;
			params[1] = light.y;
			params[7] = light.radius;
			params[8] = light.red;
			params[9] = light.green;
			params[10] = light.blue;
		}
				
		override protected function activateHook(context:Context3D):void
		{
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, params);
			context.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context.setVertexBufferAt(1, _uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
		}
		
		override protected function vertexShaderProgram():String
		{
			var program:String =
			//Jogou as coordenadas XYZ no output da tela// Não sei para que isso ainda já que esse op não aparece mais no código
			"mov op, va0 \n" +
			//Jogou o valor do mapeamento numa variável v0 para ser usado pelo fragmentShader
			"mov v0, va1 \n";
			
			return program;
		}
		
		override protected function fragmentShaderProgram():String
		{
			//fc1 = [light.x, light.y, width, height]
			//fc2 = [0, 1, 0, radius]
			//fc3 = [red, green, blue, 1(alpha)] = color
			
			var program:String =
			
			//get fragment position in xy space // Pegou Coordenada do pixel em relação ao container no eixo XY
			"mul ft0.xy, fc1.zw, v0.xy \n" +
			//get vector from fragment position to light center // Determinou a posição entre o vértice e o centro da luz fc.xy é posição da luz no container
			"sub ft1.xy, ft0.xy, fc1.xy \n" +
			//set z to 0
			"mov ft1.z, fc2.x \n" + //Copiou o valor da constante fc para a variável temporária ft1.z. Esse valor vem como zero 
			//vector to euclidean distance // Transformou o vetor com coordenadas xyz em uma grandeza x2+y2+z2 (cada um ao quadrado), 
			//depois extraiu a raíz quadrada para definir a distância no eixo XY. Agora temos a distância desse pixel para o centro da luz em um valor único
			"dp3 ft1.x, ft1.xyz, ft1.xyz \n" +	
			"sqt ft1.xyz, ft1.xyz \n" +	
			//if (distance > radius) return 1, else keep // Divide a distância pelo raio da luz. se esse resultado der maior que 1 vai retornar 1 caso contrário retorna o valor entre 0 e 1.
			"div ft1.x, ft1.x, fc2.w \n" +		
			"sat ft1.x, ft1.x \n" +
			//get brightness by subtracting value from 1 // Pega 1 e subtrai a distância (0-1) se a distância for 1 o brilho é zero, se a distância é zero o brilho é 1 e por aí vai.
			"sub ft1.x, fc2.y, ft1.x \n" +
			//multiply light color by fragment brightness	
			"mul ft1.xyz, ft1.x, ft1.xyz \n" +
			//Multiplica novamente para fazer o decaimento sendo o quadro da distância.
			"mul ft1.xyz, ft1.x, ft1.xyz \n" +
			//"mul ft1.xyz, ft1.x, fc2.w \n" +
			// Multiplica a cor, para deixar a luz com a cor escolhida
			"mul ft1.xyz, ft1.x, fc3.xyz \n" +
			//alpha = 1
			"mov ft1.w, fc3.w \n" +
			"mov oc, ft1 \n";
			
			return program;
		}
	}
}