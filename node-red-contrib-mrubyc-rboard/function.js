module.exports = function(RED) {
    
    function function_Node(config) {
        RED.nodes.createNode(this,config);
        var node = this;

        node.on('input', function(msg) {
        });
    }
    RED.nodes.registerType("function-Code",function_Node);
}