module.exports = function(RED) {
    
    function I2C_Node(config) {
        RED.nodes.createNode(this,config);
        var node = this;

        node.on('input', function(msg) {

            
        });
    }
    RED.nodes.registerType("I2C",I2C_Node);
}