module.exports = function(RED) {
    
    function GPIO_Read_Node(config) {
        RED.nodes.createNode(this,config);
        var node = this;

        node.on('input', function(msg) {

            
        });
    }
    RED.nodes.registerType("GPIO-Read",GPIO_Read_Node);
}