package SephiusEngine.Languages {

    import flash.utils.Dictionary;

    public class DialogueLanguageElement extends SimpleLanguageElement{
        /** Stores each line of a specific story text */
        public var scenes:Dictionary = new Dictionary();
        /** Store audio names for each scene */
        public var audios:Dictionary = new Dictionary();

        public function DialogueLanguageElement(elementID:String, name:String, language:String) {
            super(elementID, name, language);
        }

        public function setScene(sceneID:String, lines:Vector.<String>):void{
            scenes[sceneID] = lines;
        }
    }
}