package SephiusEngine.utils
{
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	
	/**
	 * Name of all sounds in the game and witch group they should belong.
	 * @author Fernando Rabello
	 */
	public class GameSounds
	{
		private static var _instance:GameSounds;
		
		//Interfaces
		public static const interface_select:Object =					{ name:"interface_select",						url:"assets/audio/soundFXs/Interface/UI_interface_select.mp3",									type:"UI" };  
		public static const interface_enterAccept:Object =				{ name:"interface_enterAccept",					url:"assets/audio/soundFXs/Interface/UI_interface_enterAccept.mp3",								type:"UI" };  
		public static const interface_backCancel:Object =				{ name:"interface_backCancel",					url:"assets/audio/soundFXs/Interface/UI_interface_backCancel.mp3",								type:"UI" };  
		public static const interface_start:Object =					{ name:"interface_start",						url:"assets/audio/soundFXs/Interface/UI_interface_start.mp3",									type:"UI" };  
		public static const interface_levelUp:Object =					{ name:"interface_levelUp",						url:"assets/audio/soundFXs/Interface/UI_interface_levelUp.mp3",									type:"FX" };  
		public static const interface_itemCollected:Object =			{ name:"interface_itemCollected",				url:"assets/audio/soundFXs/Interface/UI_interface_itemCollected.mp3",							type:"FX" };  
		public static const interface_spellRing:Object =				{ name:"interface_spellRing",					url:"assets/audio/soundFXs/Interface/UI_interface_spellRing.mp3",								type:"FX" };  
		public static const interface_itemRing:Object =					{ name:"interface_itemRing",					url:"assets/audio/soundFXs/Interface/UI_interface_itemRing.mp3",								type:"FX" };  
							
		//Spells										
		public static const spell_Fire:Object =							{ name:"spell_Fire",							url:"assets/audio/soundFXs/Spells/FX_spell_Fire.mp3",											type:"FX" };  
		public static const spell_Ice:Object =							{ name:"spell_Ice",								url:"assets/audio/soundFXs/Spells/FX_spell_Ice.mp3",											type:"FX" };  
		public static const spell_Water:Object =						{ name:"spell_Water",							url:"assets/audio/soundFXs/Spells/FX_spell_Water.mp3",											type:"FX" };  
		public static const spell_Earth:Object =						{ name:"spell_Earth",							url:"assets/audio/soundFXs/Spells/FX_spell_Earth.mp3",											type:"FX" };  
		public static const spell_Air:Object =							{ name:"spell_Air",								url:"assets/audio/soundFXs/Spells/FX_spell_Air.mp3",											type:"FX" };  
		public static const spell_Light:Object =						{ name:"spell_Light",							url:"assets/audio/soundFXs/Spells/FX_spell_Light.mp3",											type:"FX" };  
		public static const spell_Darkness:Object =						{ name:"spell_Darkness",						url:"assets/audio/soundFXs/Spells/FX_spell_Darkness.mp3",										type:"FX" };  
		public static const spell_Corruption:Object =					{ name:"spell_Corruption",						url:"assets/audio/soundFXs/Spells/FX_spell_Corruption.mp3",										type:"FX" };  
		public static const spell_Bio:Object =							{ name:"spell_Bio",								url:"assets/audio/soundFXs/Spells/FX_spell_Bio.mp3",											type:"FX" };  
		public static const spell_Psionica:Object =						{ name:"spell_Psionica",						url:"assets/audio/soundFXs/Spells/FX_spell_Psionica.mp3",										type:"FX" };  
														
		public static const spell_Fire_Breath:Object =					{ name:"spell_Fire_Breath",						url:"assets/audio/soundFXs/Spells/FX_spell_Fire_Breath.mp3",									type:"FX" };  
		public static const spell_Stone_Ray:Object =					{ name:"spell_Stone_Ray",						url:"assets/audio/soundFXs/Spells/FX_spell_Stone_Ray.mp3",										type:"FX" };  
		public static const spell_Fire_Ray:Object =						{ name:"spell_Fire_Ray",						url:"assets/audio/soundFXs/Spells/FX_spell_Fire_Ray.mp3",										type:"FX" };  
		public static const spell_Light_Power:Object =					{ name:"spell_Light_Power",						url:"assets/audio/soundFXs/Spells/FX_spell_Light_Power.mp3",									type:"FX" };  
		public static const spell_Dark_Flame:Object =					{ name:"spell_Dark_Flame",						url:"assets/audio/soundFXs/Spells/FX_spell_Dark_Flame.mp3",										type:"FX" };  
		public static const spell_Dark_Pulse:Object =					{ name:"spell_Dark_Pulse",						url:"assets/audio/soundFXs/Spells/FX_spell_Dark_Pulse.mp3",										type:"FX" };  
		public static const spell_Imolation:Object =					{ name:"spell_Imolation",						url:"assets/audio/soundFXs/Spells/FX_spell_Imolation.mp3",										type:"FX" };  
		public static const spell_Fire_Barrier:Object =					{ name:"spell_Fire_Barrier",					url:"assets/audio/soundFXs/Spells/FX_spell_Fire_Barrier.mp3",									type:"FX" };  
		public static const spell_Ice_Breath:Object =					{ name:"spell_Ice_Breath",						url:"assets/audio/soundFXs/Spells/FX_spell_Ice_Breath.mp3",										type:"FX" };  
		public static const spell_Cristalization:Object =				{ name:"spell_Cristalization",					url:"assets/audio/soundFXs/Spells/FX_spell_Cristalization.mp3",									type:"FX" };  
		public static const spell_Ice_Barrier:Object =					{ name:"spell_Ice_Barrier",						url:"assets/audio/soundFXs/Spells/FX_spell_Ice_Barrier.mp3",									type:"FX" };  
		public static const spell_Toxic_Breath:Object =					{ name:"spell_Toxic_Breath",					url:"assets/audio/soundFXs/Spells/FX_spell_Toxic_Breath.mp3",									type:"FX" };  
		public static const spell_Protection:Object =					{ name:"spell_Protection",						url:"assets/audio/soundFXs/Spells/FX_spell_Protection.mp3",										type:"FX" };  
		public static const spell_Earth_Teeths:Object =					{ name:"spell_Earth_Teeths",					url:"assets/audio/soundFXs/Spells/FX_spell_Earth_Teeths.mp3",									type:"FX" };  
		public static const spell_Heal:Object =							{ name:"spell_Heal",							url:"assets/audio/soundFXs/Spells/FX_spell_Heal.mp3",											type:"FX" };  
		public static const spell_Amplification:Object =				{ name:"spell_Amplification",					url:"assets/audio/soundFXs/Spells/FX_spell_Amplification.mp3",									type:"FX" };  
		public static const spell_Purification:Object =					{ name:"spell_Purification",					url:"assets/audio/soundFXs/Spells/FX_spell_Purification.mp3",									type:"FX" };  
		public static const spell_Debilitation:Object =					{ name:"spell_Debilitation",					url:"assets/audio/soundFXs/Spells/FX_spell_Debilitation.mp3",									type:"FX" };  
		public static const spell_Petrification:Object =				{ name:"spell_Petrification",					url:"assets/audio/soundFXs/Spells/FX_spell_Petrification.mp3",									type:"FX" };  
		public static const spell_Lightning:Object =					{ name:"spell_Lightning",						url:"assets/audio/soundFXs/Spells/FX_spell_Lightning.mp3",										type:"FX" };  
		public static const spell_Lightning_Orb:Object =				{ name:"spell_Lightning_Orb",					url:"assets/audio/soundFXs/Spells/FX_spell_Lightning_Orb.mp3",									type:"FX" };  
		public static const spell_Cuirass:Object =						{ name:"spell_Cuirass",							url:"assets/audio/soundFXs/Spells/FX_spell_Cuirass.mp3",										type:"FX" };  
		public static const spell_Sharp_Crystal:Object =				{ name:"spell_Sharp_Crystal",					url:"assets/audio/soundFXs/Spells/FX_spell_Sharp_Crystal.mp3",									type:"FX" };  
		public static const spell_Shiny_Crystal:Object =				{ name:"spell_Shiny_Crystal",					url:"assets/audio/soundFXs/Spells/FX_spell_Shiny_Crystal.mp3",									type:"FX" };  
		public static const spell_Incandescent_Rocks:Object =			{ name:"spell_Incandescent_Rocks",				url:"assets/audio/soundFXs/Spells/FX_spell_Incandescent_Rocks.mp3",								type:"FX" };  
		public static const spell_Summoning_Strathon:Object =			{ name:"spell_Summoning_Strathon",				url:"assets/audio/soundFXs/Spells/FX_spell_Summoning_Strathon.mp3",								type:"FX" };  
		
		public static const spell_Summoning_FireEntity:Object =			{ name:"spell_Summoning_FireEntity",			url:"assets/audio/soundFXs/Spells/FX_spell_Summoning_FireEntity.mp3",							type:"FX" }; 
		public static const spell_Super_Vision:Object =					{ name:"spell_Super_Vision",					url:"assets/audio/soundFXs/Spells/FX_spell_Super_Vision.mp3",									type:"FX" };  
		public static const spell_Wet_Splash:Object =					{ name:"spell_Wet_Splash",						url:"assets/audio/soundFXs/Spells/FX_spell_Wet_Splash.mp3",										type:"FX" };  
		//Exploded
		public static const spell_Dark_Pulse_Exploded:Object =			{ name:"spell_Dark_Pulse_Exploded",				url:"assets/audio/soundFXs/Spells/FX_spell_Dark_Pulse_Exploded.mp3",							type:"FX" };  
		public static const spell_Shiny_Crystal_Exploded:Object =		{ name:"spell_Shiny_Crystal_Exploded",			url:"assets/audio/soundFXs/Spells/FX_spell_Shiny_Crystal_Exploded.mp3",							type:"FX" };  
			
		//Splashes											
		public static const splash_Fire:Object =						{ name:"splash_Fire",							url:"assets/audio/soundFXs/FXs/FX_splash_Fire.mp3",												type:"FX" };  
		public static const splash_Ice:Object =							{ name:"splash_Ice",							url:"assets/audio/soundFXs/FXs/FX_splash_Ice.mp3",												type:"FX" };  
		public static const splash_Water:Object =						{ name:"splash_Water",							url:"assets/audio/soundFXs/FXs/FX_splash_Water.mp3",											type:"FX" };  
		public static const splash_Earth:Object =						{ name:"splash_Earth",							url:"assets/audio/soundFXs/FXs/FX_splash_Earth.mp3",											type:"FX" };  
		public static const splash_Air:Object =							{ name:"splash_Air",							url:"assets/audio/soundFXs/FXs/FX_splash_Air.mp3",												type:"FX" };  
		public static const splash_Light:Object =						{ name:"splash_Light",							url:"assets/audio/soundFXs/FXs/FX_splash_Light.mp3",											type:"FX" };  
		public static const splash_Darkness:Object =					{ name:"splash_Darkness",						url:"assets/audio/soundFXs/FXs/FX_splash_Darkness.mp3",											type:"FX" };  
		public static const splash_Corruption:Object =					{ name:"splash_Corruption",						url:"assets/audio/soundFXs/FXs/FX_splash_Corruption.mp3",										type:"FX" };  
		public static const splash_Bio:Object =							{ name:"splash_Bio",							url:"assets/audio/soundFXs/FXs/FX_splash_Bio.mp3",												type:"FX" };  
		public static const splash_Psionica:Object =					{ name:"splash_Psionica",						url:"assets/audio/soundFXs/FXs/FX_splash_Psionica.mp3",											type:"FX" };  
																		
		public static const splash_Lightning:Object =					{ name:"splash_Lightning",						url:"assets/audio/soundFXs/FXs/FX_splash_Lightning.mp3",										type:"FX" };  
		public static const splash_Dark_Pulse:Object =					{ name:"splash_Dark_Pulse",						url:"assets/audio/soundFXs/FXs/FX_splash_Dark_Pulse.mp3",										type:"FX" }; 
		public static const splash_Ice_Breath:Object =					{ name:"splash_Ice_Breath",						url:"assets/audio/soundFXs/FXs/FX_splash_Ice_Breath.mp3",										type:"FX" };  
		public static const splash_Eletric:Object =						{ name:"splash_Eletric",						url:"assets/audio/soundFXs/FXs/FX_splash_Eletric.mp3",											type:"FX" };  
																		
		public static const splash_Creature_1:Object =					{ name:"splash_Creature_1",						url:"assets/audio/soundFXs/FXs/FX_splash_Creature_1.mp3",										type:"FX" };  
		public static const splash_Creature_2:Object =					{ name:"splash_Creature_2",						url:"assets/audio/soundFXs/FXs/FX_splash_Creature_2.mp3",										type:"FX" };  
		public static const splash_Creature_3:Object =					{ name:"splash_Creature_3",						url:"assets/audio/soundFXs/FXs/FX_splash_Creature_3.mp3",										type:"FX" };  
		public static const splash_Creature_4:Object =					{ name:"splash_Creature_4",						url:"assets/audio/soundFXs/FXs/FX_splash_Creature_4.mp3",										type:"FX" };  
		public static const splash_Creature_5:Object =					{ name:"splash_Creature_5",						url:"assets/audio/soundFXs/FXs/FX_splash_Creature_5.mp3",										type:"FX" };  
		public static const splash_Metal:Object =						{ name:"splash_Metal",							url:"assets/audio/soundFXs/FXs/FX_splash_Metal.mp3",											type:"FX" };  
		public static const splash_Light_Crystal:Object =				{ name:"splash_Light_Crystal",					url:"assets/audio/soundFXs/FXs/FX_splash_Light_Crystal.mp3",									type:"FX" };  							
		public static const splash_Dark_Crystal:Object =				{ name:"splash_Dark_Crystal",					url:"assets/audio/soundFXs/FXs/FX_splash_Dark_Crystal.mp3",										type:"FX" };  							
		
		//Enviriomentals											
		public static const enviriomentals_outsideWind:Object =			{ name:"enviriomentals_outsideWind",			url:"assets/audio/soundFXs/Environments/BGFX_enviriomentals_outsideWind.mp3",					type:"BGFX" };  
		public static const enviriomentals_zoneOfOblivion:Object =		{ name:"enviriomentals_zoneOfOblivion",			url:"assets/audio/soundFXs/Environments/BGFX_enviriomentals_zoneOfOblivion.mp3",				type:"BGFX" };  
		public static const enviriomentals_lavaCave:Object =			{ name:"enviriomentals_lavaCave",				url:"assets/audio/soundFXs/Environments/BGFX_enviriomentals_lavaCave.mp3",						type:"BGFX" };  
		public static const enviriomentals_crystalCave:Object =			{ name:"enviriomentals_crystalCave",			url:"assets/audio/soundFXs/Environments/BGFX_enviriomentals_crystalCave.mp3",					type:"BGFX" };  
		public static const enviriomentals_highPass:Object =			{ name:"enviriomentals_highPass",				url:"assets/audio/soundFXs/Environments/BGFX_enviriomentals_highPass.mp3",						type:"BGFX" };  
		public static const enviriomentals_epicPlace:Object =			{ name:"enviriomentals_epicPlace",				url:"assets/audio/soundFXs/Environments/BGFX_enviriomentals_epicPlace.mp3",						type:"BGFX" };  
		public static const enviriomentals_waterFlowing:Object =		{ name:"enviriomentals_waterFlowing",			url:"assets/audio/soundFXs/Environments/BGFX_enviriomentals_waterFlowing.mp3",					type:"BGFX" };  
		public static const enviriomentals_lavaFlowing:Object =			{ name:"enviriomentals_lavaFlowing",			url:"assets/audio/soundFXs/Environments/BGFX_enviriomentals_lavaFlowing.mp3",					type:"BGFX" };  
		public static const enviriomentals_tunder:Object =				{ name:"enviriomentals_tunder",					url:"assets/audio/soundFXs/Environments/BGFX_enviriomentals_tunder.mp3",						type:"BGFX" };  
		public static const enviriomentals_caveWind:Object =			{ name:"enviriomentals_caveWind",				url:"assets/audio/soundFXs/Environments/BGFX_enviriomentals_caveWind.mp3",						type:"BGFX" };  
		public static const enviriomentals_deepCaveWind:Object =		{ name:"enviriomentals_deepCaveWind",			url:"assets/audio/soundFXs/Environments/BGFX_enviriomentals_deepCaveWind.mp3",					type:"BGFX" };  
							
		//Songs	
			//Interfaces
		public static const song_Title:Object =							{ name:"song_Title",							url:"assets/audio/Songs/BGM_song_Title.mp3",													type:"BGM" };  
			//Lands of Oblivion
		public static const song_Lands_of_Oblivion:Object =				{ name:"song_Lands_of_Oblivion",				url:"assets/audio/Songs/BGM_song_Lands_of_Oblivion.mp3",										type:"BGM" };  
		public static const song_The_High_Pass:Object =					{ name:"song_The_High_Pass",					url:"assets/audio/Songs/BGM_song_The_High_Pass.mp3",											type:"BGM" }; 
		public static const song_The_Forgotten_Deeps:Object =			{ name:"song_The_Forgotten_Deeps",				url:"assets/audio/Songs/BGM_song_The_Forgotten_Deeps.mp3",										type:"BGM" }; 
		public static const song_Ages_Between_Light_and_Darkness:Object ={ name:"song_Ages_Between_Light_and_Darkness",	url:"assets/audio/Songs/BGM_song_Ages_Between_Light_and_Darkness.mp3",							type:"BGM" };  
			//Cutscenes
		public static const song_Catharis:Object =						{ name:"song_Catharis",							url:"assets/audio/Songs/BGM_song_Catharis.mp3",													type:"BGM" }; 
		public static const song_Despise_Sorrowand_Power:Object =		{ name:"song_Despise_Sorrowand_Power",			url:"assets/audio/Songs/BGM_song_Despise_Sorrowand_Power.mp3",									type:"BGM" }; 
		public static const song_Epic_Epiphany:Object =					{ name:"song_Epic_Epiphany",					url:"assets/audio/Songs/BGM_song_Epic_Epiphany.mp3",											type:"BGM" }; 
		public static const song_The_Phenomenal_Battle:Object =			{ name:"song_The_Phenomenal_Battle",			url:"assets/audio/Songs/BGM_song_The_Phenomenal_Battle.mp3",									type:"BGM" }; 
		public static const song_The_Phenonal_Quest:Object =			{ name:"song_The_Phenonal_Quest",				url:"assets/audio/Songs/BGM_song_The_Phenonal_Quest.mp3",										type:"BGM" }; 
			//Events
		public static const song_Game_Over:Object =						{ name:"song_Game_Over",						url:"assets/audio/Songs/BGM_song_Game_Over.mp3",												type:"BGM" };  
		
		
		//Characters											
			//Sephius											
		public static const sephius_walking:Object =					{ name:"FX_sephius_walking",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_walking.mp3",							type:"FX" };  
		public static const sephius_walking_back:Object =				{ name:"FX_sephius_walking_back",				url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_walking.mp3",							type:"FX" };  
		public static const sephius_ducking:Object =					{ name:"FX_sephius_ducking",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_ducking.mp3",							type:"FX" };  
		public static const sephius_skid:Object =						{ name:"FX_sephius_skid",						url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_skid.mp3",								type:"FX" };  
		public static const sephius_stoping:Object =					{ name:"FX_sephius_stoping",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_stopping.mp3",							type:"FX" };  
		public static const sephius_absorbing:Object =					{ name:"FX_sephius_absorbing",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_absorbing.mp3",						type:"FX" };  
		public static const sephius_shield:Object =						{ name:"FX_sephius_shield",						url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_shield.mp3",							type:"FX" };  
		public static const sephius_shield_damage:Object =				{ name:"FX_sephius_shield_damage",				url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_shield_damage.mp3",					type:"FX" };  
		public static const sephius_shieldOn:Object =					{ name:"FX_sephius_shieldOn",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_shieldOn.mp3",							type:"FX" };  
		public static const sephius_ShieldOff:Object =					{ name:"FX_sephius_ShieldOff",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_ShieldOff.mp3",						type:"FX" };  
		public static const sephius_casting:Object =					{ name:"FX_sephius_casting",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_casting.mp3",							type:"FX" };  
		public static const sephius_cast:Object =						{ name:"FX_sephius_cast",						url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_cast.mp3",								type:"FX" };  
		public static const sephius_landing:Object =					{ name:"FX_sephius_landing",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_landing.mp3",							type:"FX" };  
		public static const sephius_jumping:Object =					{ name:"FX_sephius_jumping",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_jumping.mp3",							type:"FX" };
		public static const sephius_hammerJump:Object =					{ name:"FX_sephius_hammerJump",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_hammerJump.mp3",						type:"FX" };
		public static const sephius_flying:Object =						{ name:"FX_sephius_flying",						url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_flying.mp3",							type:"FX" };
		public static const sephius_stop_flying:Object =				{ name:"FX_sephius_stop_flying",				url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_stop_flying.mp3",						type:"FX" };
		public static const sephius_gliding:Object =					{ name:"FX_sephius_gliding",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_gliding.mp3",							type:"FX" };
		public static const sephius_falling:Object =					{ name:"FX_sephius_falling",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_falling.mp3",							type:"FX" };
		public static const sephius_dodge:Object =						{ name:"FX_sephius_dodge",						url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_dodge.mp3",							type:"FX" };
		public static const sephius_movment:Object =					{ name:"FX_sephius_movment",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_movment.mp3",							type:"FX" };
		public static const sephius_step1:Object =						{ name:"FX_sephius_step1",						url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_step1.mp3",							type:"FX" };  
		public static const sephius_step2:Object =						{ name:"FX_sephius_step2",						url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_step2.mp3",							type:"FX" };  
		public static const sephius_step3:Object =						{ name:"FX_sephius_step3",						url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_step3.mp3",							type:"FX" };  
		public static const sephius_step4:Object =						{ name:"FX_sephius_step4",						url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_step4.mp3",							type:"FX" };  
		public static const sephius_step5:Object =						{ name:"FX_sephius_step5",						url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_step5.mp3",							type:"FX" };  
		public static const sephius_step6:Object =						{ name:"FX_sephius_step6",						url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_step6.mp3",							type:"FX" };  
		public static const sephius_step7:Object =						{ name:"FX_sephius_step7",						url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_step7.mp3",							type:"FX" };  
		public static const sephius_step8:Object =						{ name:"FX_sephius_step8",						url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_step8.mp3",							type:"FX" };  
		public static const sephius_damage1:Object =					{ name:"FX_sephius_damage1",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_damage1.mp3",							type:"FX" };  
		public static const sephius_damage2:Object =					{ name:"FX_sephius_damage2",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_damage2.mp3",							type:"FX" };  
		public static const sephius_damage3:Object =					{ name:"FX_sephius_damage3",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_damage3.mp3",							type:"FX" };  
		public static const sephius_damage4:Object =					{ name:"FX_sephius_damage4",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_damage4.mp3",							type:"FX" };  
		public static const sephius_damage5:Object =					{ name:"FX_sephius_damage5",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_damage5.mp3",							type:"FX" };  
		public static const sephius_damage6:Object =					{ name:"FX_sephius_damage6",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_damage6.mp3",							type:"FX" };  
		public static const sephius_damage7:Object =					{ name:"FX_sephius_damage7",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_damage7.mp3",							type:"FX" };  
		public static const sephius_amorImpact1:Object =				{ name:"FX_sephius_amorImpact1",				url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_amorImpact1.mp3",						type:"FX" };  
		public static const sephius_amorImpact2:Object =				{ name:"FX_sephius_amorImpact2",				url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_amorImpact2.mp3",						type:"FX" };  
		public static const sephius_amorImpact3:Object =				{ name:"FX_sephius_amorImpact3",				url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_amorImpact3.mp3",						type:"FX" };  
		public static const sephius_amorImpact4:Object =				{ name:"FX_sephius_amorImpact4",				url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_amorImpact4.mp3",						type:"FX" };  
		public static const sephius_amorImpact5:Object =				{ name:"FX_sephius_amorImpact5",				url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_amorImpact5.mp3",						type:"FX" };  
		public static const sephius_amorImpact6:Object =				{ name:"FX_sephius_amorImpact6",				url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_amorImpact6.mp3",						type:"FX" };  
		public static const sephius_amorImpact7:Object =				{ name:"FX_sephius_amorImpact7",				url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_amorImpact7.mp3",						type:"FX" };  
		public static const sephius_dyingDamage1:Object =				{ name:"FX_sephius_dyingDamage1",				url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_dyingDamage1.mp3",						type:"FX" };  
		public static const sephius_dyingDamage2:Object =				{ name:"FX_sephius_dyingDamage2",				url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_dyingDamage2.mp3",						type:"FX" };  
		public static const sephius_dyingDamage3:Object =				{ name:"FX_sephius_dyingDamage3",				url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_dyingDamage3.mp3",						type:"FX" }; 
		public static const sephius_strongAttackFast:Object =			{ name:"FX_sephius_strongAttackFast",			url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_strongAttackFast.mp3",					type:"FX" }; 
		public static const sephius_strongAttackSlow:Object =			{ name:"FX_sephius_strongAttackSlow",			url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_strongAttackSlow.mp3",					type:"FX" }; 
		public static const sephius_strongAttackSlowAir:Object =		{ name:"FX_sephius_strongAttackSlowAir",		url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_strongAttackSlowAir.mp3",				type:"FX" }; 
		public static const sephius_shorriuken:Object =					{ name:"FX_sephius_shorriuken",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_shorriuken.mp3",						type:"FX" }; 
		public static const sephius_hammerattack:Object =				{ name:"FX_sephius_hammerattack",				url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_hammerattack.mp3",						type:"FX" };  
		public static const sephius_razante:Object =					{ name:"FX_sephius_razante",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_razante.mp3",							type:"FX" };  
		public static const sephius_attack1:Object =					{ name:"FX_sephius_attack1",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_attack1.mp3",							type:"FX" }; 
		public static const sephius_attack2:Object =					{ name:"FX_sephius_attack2",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_attack2.mp3",							type:"FX" }; 
		public static const sephius_attack3:Object =					{ name:"FX_sephius_attack3",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_attack3.mp3",							type:"FX" }; 
		public static const sephius_attack4:Object =					{ name:"FX_sephius_attack4",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_attack4.mp3",							type:"FX" }; 
		public static const sephius_weakspell1:Object =					{ name:"FX_sephius_weakspell1",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_weakspell1.mp3",						type:"FX" }; 
		public static const sephius_weakspell2:Object =					{ name:"FX_sephius_weakspell2",					url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_weakspell2.mp3",						type:"FX" }; 
		public static const folken_energy:Object =						{ name:"FX_folken_energy",						url:"assets/audio/soundFXs/Characters/sephius/FX_folken_energy.mp3",							type:"FX" };
		public static const sephius_death:Object =						{ name:"FX_sephius_death",						url:"assets/audio/soundFXs/Characters/sephius/FX_sephius_death.mp3",							type:"FX" };
										
			//Lokmo A								
		public static const lokmo_damage1:Object =						{ name:"lokmo_damage1",							url:"assets/audio/soundFXs/Characters/lokmo/FX_lokmo_damage1.mp3",								type:"FX" };
		public static const lokmo_damage2:Object =						{ name:"lokmo_damage2",							url:"assets/audio/soundFXs/Characters/lokmo/FX_lokmo_damage2.mp3",								type:"FX" };
		public static const lokmo_walking:Object =						{ name:"lokmo_walking",							url:"assets/audio/soundFXs/Characters/lokmo/FX_lokmo_walking.mp3",								type:"FX" };
		public static const lokmo_attack1:Object =						{ name:"lokmo_attack1",							url:"assets/audio/soundFXs/Characters/lokmo/FX_lokmo_attack1.mp3",								type:"FX" };
		public static const lokmo_attack2:Object =						{ name:"lokmo_attack2",							url:"assets/audio/soundFXs/Characters/lokmo/FX_lokmo_attack2.mp3",								type:"FX" };
		public static const lokmo_defending:Object =					{ name:"lokmo_defending",						url:"assets/audio/soundFXs/Characters/lokmo/FX_lokmo_defending.mp3",							type:"FX" };
		public static const lokmo_defendHit:Object =					{ name:"lokmo_defendHit",						url:"assets/audio/soundFXs/Characters/lokmo/FX_lokmo_defendHit.mp3",							type:"FX" };
		public static const lokmo_dying:Object =						{ name:"lokmo_dying",							url:"assets/audio/soundFXs/Characters/lokmo/FX_lokmo_dying.mp3",								type:"FX" };
		public static const lokmo_loosingEssence:Object =				{ name:"lokmo_loosingEssence",					url:"assets/audio/soundFXs/Characters/lokmo/FX_lokmo_loosingEssence.mp3",						type:"FX" };
		public static const lokmo_death:Object =						{ name:"lokmo_death",							url:"assets/audio/soundFXs/Characters/lokmo/FX_lokmo_death.mp3",								type:"FX" };
										
			//Guenon								
		public static const guehnon_step1:Object =						{ name:"guehnon_step1",							url:"assets/audio/soundFXs/Characters/guehnon/FX_guehnon_step1.mp3",							type:"FX" };  
		public static const guehnon_step2:Object =						{ name:"guehnon_step2",							url:"assets/audio/soundFXs/Characters/guehnon/FX_guehnon_step2.mp3",							type:"FX" };  
		public static const guehnon_step3:Object =						{ name:"guehnon_step3",							url:"assets/audio/soundFXs/Characters/guehnon/FX_guehnon_step3.mp3",							type:"FX" };  
		public static const guehnon_step4:Object =						{ name:"guehnon_step4",							url:"assets/audio/soundFXs/Characters/guehnon/FX_guehnon_step4.mp3",							type:"FX" };  
		public static const guehnon_attackPaw:Object =					{ name:"guehnon_attackPaw",						url:"assets/audio/soundFXs/Characters/guehnon/FX_guehnon_attackPaw.mp3",						type:"FX" };
		public static const guehnon_attackBite:Object =					{ name:"guehnon_attackBite",					url:"assets/audio/soundFXs/Characters/guehnon/FX_guehnon_attackBite.mp3",						type:"FX" };
		public static const guehnon_attackJump:Object =					{ name:"guehnon_attackJump",					url:"assets/audio/soundFXs/Characters/guehnon/FX_guehnon_attackJump.mp3",						type:"FX" };
		public static const guehnon_rising:Object =						{ name:"guehnon_rising",						url:"assets/audio/soundFXs/Characters/guehnon/FX_guehnon_rising.mp3",							type:"FX" };
		public static const guehnon_lowering:Object =					{ name:"guehnon_lowering",						url:"assets/audio/soundFXs/Characters/guehnon/FX_guehnon_lowering.mp3",							type:"FX" };
		public static const guehnon_damage:Object =						{ name:"guehnon_damage",						url:"assets/audio/soundFXs/Characters/guehnon/FX_guehnon_Damage.mp3",							type:"FX" };
		public static const guehnon_dying:Object =						{ name:"guehnon_dying",							url:"assets/audio/soundFXs/Characters/guehnon/FX_guehnon_dying.mp3",							type:"FX" };
		public static const guehnon_loosingEssence:Object =				{ name:"guehnon_loosingEssence",				url:"assets/audio/soundFXs/Characters/guehnon/FX_guehnon_loosingEssence.mp3",					type:"FX" };
		public static const guehnon_death:Object =						{ name:"guehnon_death",							url:"assets/audio/soundFXs/Characters/guehnon/FX_guehnon_death.mp3",							type:"FX" };
											
			//StoneEntity								
		public static const stoneEntity_impact:Object =					{ name:"stoneEntity_impact",					url:"assets/audio/soundFXs/Characters/stoneEntity/FX_stoneEntity_impact.mp3",					type:"FX" };
		public static const stoneEntity_step:Object =					{ name:"stoneEntity_step",						url:"assets/audio/soundFXs/Characters/stoneEntity/FX_stoneEntity_step.mp3",						type:"FX" };
		public static const stoneEntity_step1:Object =					{ name:"stoneEntity_step1",						url:"assets/audio/soundFXs/Characters/stoneEntity/FX_stoneEntity_step1.mp3",					type:"FX" };  
		public static const stoneEntity_step2:Object =					{ name:"stoneEntity_step2",						url:"assets/audio/soundFXs/Characters/stoneEntity/FX_stoneEntity_step2.mp3",					type:"FX" };  
		public static const stoneEntity_step3:Object =					{ name:"stoneEntity_step3",						url:"assets/audio/soundFXs/Characters/stoneEntity/FX_stoneEntity_step3.mp3",					type:"FX" };  
		public static const stoneEntity_step4:Object =					{ name:"stoneEntity_step4",						url:"assets/audio/soundFXs/Characters/stoneEntity/FX_stoneEntity_step4.mp3",					type:"FX" };  
		public static const stoneEntity_attackTreading:Object =			{ name:"stoneEntity_attackTreading",			url:"assets/audio/soundFXs/Characters/stoneEntity/FX_stoneEntity_attackTreading.mp3",			type:"FX" };
		public static const stoneEntity_attackSmashing:Object =			{ name:"stoneEntity_attackSmashing",			url:"assets/audio/soundFXs/Characters/stoneEntity/FX_stoneEntity_attackSmashing.mp3",			type:"FX" };
		public static const stoneEntity_damage:Object =					{ name:"stoneEntity_damage",					url:"assets/audio/soundFXs/Characters/stoneEntity/FX_stoneEntity_damage.mp3",					type:"FX" };
		public static const stoneEntity_loosingEssence:Object =			{ name:"stoneEntity_loosingEssence",			url:"assets/audio/soundFXs/Characters/stoneEntity/FX_stoneEntity_loosingEssence.mp3",			type:"FX" };
		public static const stoneEntity_dying:Object =					{ name:"stoneEntity_dying",						url:"assets/audio/soundFXs/Characters/stoneEntity/FX_stoneEntity_dying.mp3",					type:"FX" };
		public static const stoneEntity_death	:Object =				{ name:"stoneEntity_death",						url:"assets/audio/soundFXs/Characters/stoneEntity/FX_stoneEntity_death.mp3",					type:"FX" };
							
			//Seth                                           					
		public static const seth_staying:Object =                		{ name:"seth_staying",							url:"assets/audio/soundFXs/Characters/seth/FX_seth_staying.mp3",								type:"FX" };
		public static const seth_attack:Object =                 		{ name:"seth_attack",							url:"assets/audio/soundFXs/Characters/seth/FX_seth_attack.mp3",									type:"FX" };
		public static const seth_spell:Object =                  		{ name:"seth_spell",							url:"assets/audio/soundFXs/Characters/seth/FX_seth_spell.mp3",									type:"FX" };
		public static const seth_damage:Object =                 		{ name:"seth_damage",							url:"assets/audio/soundFXs/Characters/seth/FX_seth_damage.mp3",									type:"FX" };
		public static const seth_death:Object =                  		{ name:"seth_death",							url:"assets/audio/soundFXs/Characters/seth/FX_seth_death.mp3",									type:"FX" };
																				
			//IceEntity                                      					
		public static const iceEntity_walking:Object =           		{ name:"iceEntity_walking",						url:"assets/audio/soundFXs/Characters/iceEntity/FX_iceEntity_walking.mp3",						type:"FX" };
		public static const iceEntity_attackPunch:Object =       		{ name:"iceEntity_attackPunch",					url:"assets/audio/soundFXs/Characters/iceEntity/FX_iceEntity_attackPunch.mp3",					type:"FX" };
		public static const iceEntity_attackKick:Object =        		{ name:"iceEntity_attackKick",					url:"assets/audio/soundFXs/Characters/iceEntity/FX_iceEntity_attackKick.mp3",					type:"FX" };
		public static const iceEntity_spell:Object =             		{ name:"iceEntity_spell",						url:"assets/audio/soundFXs/Characters/iceEntity/FX_iceEntity_spell.mp3",						type:"FX" };
		public static const iceEntity_dying:Object =             		{ name:"iceEntity_dying",						url:"assets/audio/soundFXs/Characters/iceEntity/FX_iceEntity_dying.mp3",						type:"FX" };
		public static const iceEntity_damage:Object =            		{ name:"iceEntity_damage",						url:"assets/audio/soundFXs/Characters/iceEntity/FX_iceEntity_damage.mp3",						type:"FX" };
		public static const iceEntity_loosingEssence:Object =    		{ name:"iceEntity_loosingEssence",				url:"assets/audio/soundFXs/Characters/iceEntity/FX_iceEntity_loosingEssence.mp3",				type:"FX" };
		public static const iceEntity_death:Object =             		{ name:"iceEntity_death",						url:"assets/audio/soundFXs/Characters/iceEntity/FX_iceEntity_death.mp3",						type:"FX" };
																				
			//Plathanus                                       					
		public static const plathanus_staying:Object =           		{ name:"plathanus_staying",						url:"assets/audio/soundFXs/Characters/plathanus/FX_plathanus_staying.mp3",						type:"FX" };
		public static const plathanus_attack:Object =            		{ name:"plathanus_attack",						url:"assets/audio/soundFXs/Characters/plathanus/FX_plathanus_attack.mp3",						type:"FX" };
		public static const plathanus_spell:Object =             		{ name:"plathanus_spell",						url:"assets/audio/soundFXs/Characters/plathanus/FX_plathanus_spell.mp3",						type:"FX" };
		public static const plathanus_damage :Object =           		{ name:"plathanus_damage",						url:"assets/audio/soundFXs/Characters/plathanus/FX_plathanus_damage.mp3",						type:"FX" };
		public static const plathanus_death:Object =             		{ name:"plathanus_death",						url:"assets/audio/soundFXs/Characters/plathanus/FX_plathanus_death.mp3",						type:"FX" };
																				
			//Thomor                                        					
		public static const thomor_flying:Object =               		{ name:"thomor_flying",							url:"assets/audio/soundFXs/Characters/thomor/FX_thomor_flying.mp3",								type:"FX" };
		public static const thomor_damage:Object =               		{ name:"thomor_damage",							url:"assets/audio/soundFXs/Characters/thomor/FX_thomor_damage.mp3",								type:"FX" };
		public static const thomor_death:Object =                		{ name:"thomor_death",							url:"assets/audio/soundFXs/Characters/thomor/FX_thomor_death.mp3",								type:"FX" };
																				
			//Disertheus                                      					
		public static const disertheus_dlying:Object =           		{ name:"disertheus_dlying",						url:"assets/audio/soundFXs/Characters/disertheus/FX_disertheus_dlying.mp3",						type:"FX" };
		public static const disertheus_spell:Object =            		{ name:"disertheus_spell",						url:"assets/audio/soundFXs/Characters/disertheus/FX_disertheus_spell.mp3",						type:"FX" };
		public static const disertheus_damage:Object =           		{ name:"disertheus_damage",						url:"assets/audio/soundFXs/Characters/disertheus/FX_disertheus_damage.mp3",						type:"FX" };
		public static const disertheus_death:Object =            		{ name:"disertheus_death",						url:"assets/audio/soundFXs/Characters/disertheus/FX_disertheus_death.mp3",						type:"FX" };
																						
			//Crippling Vulgoh                                						
		public static const cripplingVulgoh_crawling:Object =    		{ name:"cripplingVulgoh_crawling",				url:"assets/audio/soundFXs/Characters/cripplingVulgoh/FX_cripplingVulgoh_crawling.mp3",			type:"FX" };
		public static const cripplingVulgoh_damage:Object =      		{ name:"cripplingVulgoh_damage",				url:"assets/audio/soundFXs/Characters/cripplingVulgoh/FX_cripplingVulgoh_damage.mp3",			type:"FX" };
		public static const cripplingVulgoh_death:Object =       		{ name:"cripplingVulgoh_death",					url:"assets/audio/soundFXs/Characters/cripplingVulgoh/FX_cripplingVulgoh_death.mp3",			type:"FX" };
																						
			//Vulgoh                                           					
		public static const vulgoh_walking:Object =	           			{ name:"vulgoh_walking",						url:"assets/audio/soundFXs/Characters/vulgoh/FX_vulgoh_walking.mp3",							type:"FX" };
																					
		//Boses                                                						
			//Nomegah                                          						
		public static const nomegah_landing:Object =             		{ name:"nomegah_landing",						url:"assets/audio/soundFXs/Characters/nomegah/FX_nomegah_landing.mp3",							type:"FX" };
		public static const nomegah_attack1:Object =             		{ name:"nomegah_attack1",						url:"assets/audio/soundFXs/Characters/nomegah/FX_nomegah_attack1.mp3",							type:"FX" };
		public static const nomegah_attack2:Object =             		{ name:"nomegah_attack2",						url:"assets/audio/soundFXs/Characters/nomegah/FX_nomegah_attack2.mp3",							type:"FX" };
		public static const nomegah_attack3:Object =             		{ name:"nomegah_attack3",						url:"assets/audio/soundFXs/Characters/nomegah/FX_nomegah_attack3.mp3",							type:"FX" };
		public static const nomegah_spell:Object =               		{ name:"nomegah_spell",							url:"assets/audio/soundFXs/Characters/nomegah/FX_nomegah_spell.mp3",							type:"FX" };
		public static const nomegah_damage:Object =              		{ name:"nomegah_damage",						url:"assets/audio/soundFXs/Characters/nomegah/FX_nomegah_damage.mp3",							type:"FX" };
		public static const nomegah_flying:Object =              		{ name:"nomegah_flying",						url:"assets/audio/soundFXs/Characters/nomegah/FX_nomegah_flying.mp3",							type:"FX" };
		public static const nomegah_rasante:Object =             		{ name:"nomegah_rasante",						url:"assets/audio/soundFXs/Characters/nomegah/FX_nomegah_rasante.mp3",							type:"FX" };
																					
			//Phenomenal Entity						
		public static const phenomenalEntity_rising:Object =     		{ name:"phenomenalEntity_rising",				url:"assets/audio/soundFXs/Characters/phenomenalEntity/FX_phenomenalEntity_rising.mp3",			type:"FX" };
		public static const phenomenalEntity_walking:Object =    		{ name:"phenomenalEntity_walking",				url:"assets/audio/soundFXs/Characters/phenomenalEntity/FX_phenomenalEntity_walking.mp3",		type:"FX" };
		public static const phenomenalEntity_smashing:Object =   		{ name:"phenomenalEntity_smashing",				url:"assets/audio/soundFXs/Characters/phenomenalEntity/FX_phenomenalEntity_smashing.mp3",		type:"FX" };
		public static const phenomenalEntity_falling:Object =    		{ name:"phenomenalEntity_falling",				url:"assets/audio/soundFXs/Characters/phenomenalEntity/FX_phenomenalEntity_falling.mp3",		type:"FX" };
		public static const phenomenalEntity_openingHead:Object =		{ name:"phenomenalEntity_openingHead",			url:"assets/audio/soundFXs/Characters/phenomenalEntity/FX_phenomenalEntity_openingHead.mp3",	type:"FX" };
		public static const phenomenalEntity_spell:Object =      		{ name:"phenomenalEntity_spell",				url:"assets/audio/soundFXs/Characters/phenomenalEntity/FX_phenomenalEntity_spell.mp3",			type:"FX" };
		public static const phenomenalEntity_lowering:Object =   		{ name:"phenomenalEntity_lowering",				url:"assets/audio/soundFXs/Characters/phenomenalEntity/FX_phenomenalEntity_lowering.mp3",		type:"FX" };
			
		//Objects
		public static const object_geiser_stream:Object =    			{ name:"object_geiser_stream",					url:"assets/audio/soundFXs/Objects/FX_object_geiser_stream.mp3",								type:"FX" };
		public static const object_barrier_oppening:Object =    		{ name:"object_barrier_oppening",				url:"assets/audio/soundFXs/Objects/FX_object_barrier_oppening.mp3",								type:"FX" };
		public static const object_plataform_collapsing:Object =    	{ name:"object_plataform_collapsing",			url:"assets/audio/soundFXs/Objects/FX_object_plataform_collapsing.mp3",							type:"FX" };
		public static const object_gem_broking:Object =    				{ name:"object_gem_broking",					url:"assets/audio/soundFXs/Objects/FX_object_gem_broking.mp3",									type:"FX" };
		public static const object_deepEssence_staying:Object =    		{ name:"object_deepEssence_staying",			url:"assets/audio/soundFXs/Objects/FX_object_deepEssence_staying.mp3",							type:"FX" };
		public static const object_deepEssence_flowing:Object =    		{ name:"object_deepEssence_flowing",			url:"assets/audio/soundFXs/Objects/FX_object_deepEssence_flowing.mp3",							type:"FX" };
		public static const object_mysticalEssence_staying:Object =    	{ name:"object_mysticalEssence_staying",		url:"assets/audio/soundFXs/Objects/FX_object_mysticalEssence_staying.mp3",						type:"FX" };
		public static const object_mysticalEssence_flowing:Object =    	{ name:"object_mysticalEssence_flowing",		url:"assets/audio/soundFXs/Objects/FX_object_mysticalEssence_flowing.mp3",						type:"FX" };
		public static const object_temperedEssence_staying:Object =    	{ name:"object_temperedEssence_staying",		url:"assets/audio/soundFXs/Objects/FX_object_temperedEssence_staying.mp3",						type:"FX" };
		public static const object_temperedEssence_flowing:Object =    	{ name:"object_temperedEssence_flowing",		url:"assets/audio/soundFXs/Objects/FX_object_temperedEssence_flowing.mp3",						type:"FX" };
		public static const object_savePryre_activating:Object =    	{ name:"object_savePryre_activating",			url:"assets/audio/soundFXs/Objects/FX_object_savePryre_activating.mp3",							type:"FX" };
		public static const object_mysticReceptacle_activating:Object = { name:"object_mysticReceptacle_activating",	url:"assets/audio/soundFXs/Objects/FX_object_mysticReceptacle_activating.mp3",					type:"FX" };
		public static const object_groundButtom_activating:Object =   	{ name:"object_groundButtom_activating",		url:"assets/audio/soundFXs/Objects/FX_object_groundButtom_activating.mp3",						type:"FX" };
		public static const object_lanceTrap_activating:Object =    	{ name:"object_lanceTrap_activating",			url:"assets/audio/soundFXs/Objects/FX_object_lanceTrap_activating.mp3",							type:"FX" };
		public static const object_laminaTrap_activating:Object =    	{ name:"object_laminaTrap_activating",			url:"assets/audio/soundFXs/Objects/FX_object_laminaTrap_activating.mp3",						type:"FX" };
		public static const object_rock_impact:Object =    				{ name:"object_rock_impact",					url:"assets/audio/soundFXs/Objects/FX_object_rock_impact.mp3",									type:"FX" };
		public static const object_cloth_flaging:Object =    			{ name:"object_cloth_flaging",					url:"assets/audio/soundFXs/Objects/FX_object_cloth_flaging.mp3",								type:"FX" };
		
		public function GameSounds(pvc:publicClass)
		{
			initialize();
			trace ("GameSounds Created");
		}
		
		/**
		 * Get this singleton instance of GameSounds
		 * @return
		 */
		public static function getInstance():GameSounds 
		{
			if (!_instance)
				_instance = new GameSounds(new publicClass());
			return _instance;
		}
		
		private function initialize():void
		{
			//createAllSounds();
		}
		
		/**
		 * Get all static public variables and add a sound for each of one.
		 * Other classes that need to create a sound can just find sound information here, no need to manually put the name and url for sounds externally.
		 */
		private function createAllSounds():void
		{ 
			/*OLD CODE 
			//Get an XML description of this class 
			//and return the variable types as XMLList with e4x 
			var varList:XMLList = describeType(GameSounds).variable;
			//trace (varList);
			for (var i:int; i < varList.length(); i++)
			{
				//Show the name and the value 
				//trace(GameSounds[varList[i].@name].name, GameSounds[varList[i].@name].url, GameSounds[varList[i].@name].type);
				
				var soundID:String = GameSounds[varList[i].@name].name;
				var soundURL:String = GameSounds[varList[i].@name].url;
				var soundType:String = GameSounds[varList[i].@name].type;
				
				SephiusEngineEngine.getInstance().sound.addSound(soundID, soundURL, soundType);
			}		
			*/
		}
	}
}

class publicClass {}