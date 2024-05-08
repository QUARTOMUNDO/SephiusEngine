package SephiusEngine.Languages {
    public class UILanguageElement extends SimpleLanguageElement{
        public var help:String;

        public function UILanguageElement(elementID:String, language:String) {
            super(elementID, null, language);
        }

        public function setName(name:String):void{
            this.name = name;
        }

        public function setHelp(help:String):void{
            this.help = help;
        }
    }
}