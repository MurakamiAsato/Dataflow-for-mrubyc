module.exports = function(RED) {
    
    function Constant_Node(config) {
        RED.nodes.createNode(this,config);
        var node = this;

        node.on('input', function(msg) {


        });
    }
    RED.nodes.registerType("Constant",Constant_Node);
}