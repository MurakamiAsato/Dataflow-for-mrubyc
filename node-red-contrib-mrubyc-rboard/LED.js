module.exports = function(RED) {
    
    function LED_Node(config) {
        RED.nodes.createNode(this,config);
        this.targetPort = config.targetPort;
        this.onBoardLED = config.onBoardLED;
        var node = this;

        node.on('input', function(msg) {

            if(node.targetPort != "" && node.onBoardLED != "0"){
                msg.payload = "「ポート番号」と「オンボードLED番号」の両方が設定されています。どちらかのみ設定してください"
            }else if(node.targetPort != ""){                               
                msg.payload = "ポート番号："+ node.targetPort + "番が点灯します";
            }else if(node.onBoardLED != "0"){
                msg.payload = "オンボードLEDが「"+ node.onBoardLED + "」の2進数形式で点灯します";
            }else{
                msg.payload =　"LEDノードが機能しません"
            }

            node.send(msg);

        });
    }
    RED.nodes.registerType("LED",LED_Node);
}