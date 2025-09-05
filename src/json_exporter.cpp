#include "json_exporter.h"
#include <sstream>
#include <algorithm>

namespace codemap {

std::string JsonExporter::escapeJSON(const std::string& str) {
    // PSEUDOCODE:
    // for each character in str:
    //     if char is '"': append \"
    //     if char is '\': append \\
    //     if char is '\n': append \n
    //     if char is '\r': append \r
    //     if char is '\t': append \t
    //     else: append char
    
    std::string result;
    for (char c : str) {
        switch (c) {
            case '"': result += "\\\""; break;
            case '\\': result += "\\\\"; break;
            case '\n': result += "\\n"; break;
            case '\r': result += "\\r"; break;
            case '\t': result += "\\t"; break;
            default: result += c; break;
        }
    }
    return result;
}

std::string JsonExporter::graphToJSON(const FunctionGraph& graph) {
    // PSEUDOCODE:
    // create JSON object
    // add nodes array:
    //     for each node:
    //         add node object with all properties
    // add edges array:
    //     for each edge:
    //         add edge object with from/to indices
    // return JSON string
    
    std::ostringstream json;
    json << "{\n";
    
    // Export nodes
    json << "  \"nodes\": [\n";
    for (size_t i = 0; i < graph.nodes.size(); ++i) {
        const auto& node = graph.nodes[i];
        json << "    {\n";
        json << "      \"name\": \"" << escapeJSON(node.name) << "\",\n";
        json << "      \"file\": \"" << escapeJSON(node.file) << "\",\n";
        json << "      \"line\": " << node.line << ",\n";
        json << "      \"isStub\": " << (node.isStub ? "true" : "false") << ",\n";
        json << "      \"isMissing\": " << (node.isMissing ? "true" : "false") << ",\n";
        json << "      \"isExternal\": " << (node.isExternal ? "true" : "false") << "\n";
        json << "    }";
        if (i < graph.nodes.size() - 1) json << ",";
        json << "\n";
    }
    json << "  ],\n";
    
    // Export edges
    json << "  \"edges\": [\n";
    for (size_t i = 0; i < graph.edges.size(); ++i) {
        const auto& edge = graph.edges[i];
        json << "    {\n";
        json << "      \"from\": " << edge.first << ",\n";
        json << "      \"to\": " << edge.second << "\n";
        json << "    }";
        if (i < graph.edges.size() - 1) json << ",";
        json << "\n";
    }
    json << "  ]\n";
    
    json << "}";
    return json.str();
}

FunctionGraph JsonExporter::jsonToGraph(const std::string& jsonString) {
    // PSEUDOCODE:
    // parse JSON string
    // create empty graph
    // for each node in JSON:
    //     create FunctionNode from JSON properties
    //     add to graph
    // for each edge in JSON:
    //     add edge to graph
    // return graph
    
    // TODO: Implement proper JSON parsing
    // For now, return empty graph as placeholder
    FunctionGraph graph;
    
    // This is a simplified implementation for testing
    // In production, use a proper JSON library like nlohmann/json
    
    return graph;
}

bool JsonExporter::isValidGraphJSON(const std::string& jsonString) {
    // PSEUDOCODE:
    // try to parse JSON
    // check if has "nodes" array
    // check if has "edges" array
    // check if each node has required fields
    // check if each edge has "from" and "to"
    // return true if all checks pass
    
    // Basic validation - check for required fields
    if (jsonString.find("\"nodes\"") == std::string::npos) return false;
    if (jsonString.find("\"edges\"") == std::string::npos) return false;
    
    // Check for balanced braces
    int braceCount = 0;
    for (char c : jsonString) {
        if (c == '{' || c == '[') braceCount++;
        if (c == '}' || c == ']') braceCount--;
        if (braceCount < 0) return false;
    }
    
    return braceCount == 0;
}

} // namespace codemap