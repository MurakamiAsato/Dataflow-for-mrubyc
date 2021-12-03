module.exports = function(RED) {
    
    function GPIO_Write1_Node(config) {
        RED.nodes.createNode(this,config);
        var node = this;

        node.on('input', function(msg) {

            
        });
    }
    RED.nodes.registerType("GPIO-Write-1",GPIO_Write1_Node);
}