package SephiusEngine.Languages {
    public class LoreLanguageElement extends SimpleLanguageElement{
        public var usage:String;
        public var description:Vector.<String> = new Vector.<String>();

        public function LoreLanguageElement(elementID:String, language:String) {
            super(elementID, null, language);
        }

        public function setName(name:String, page:int = 0):void{
            this.name = name;
        }

        public function setUsage(usage:String, page:int = 0):void{
            this.usage = usage;
        }

        public function setDescription(description:String, page:int):void{
            if(page > 0 && page > description.length -1)
                throw Error("[LORE LANGUAGE ELEMENT] Pages before this is missing: " +  " page : " + page);
                
            this.description[page] = description;
        }
    }
}