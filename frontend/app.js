// CodeMap Frontend Application
// Main JavaScript file for the interactive call graph visualization

// Global variables
let cy = null;  // Cytoscape instance
let graphData = null;  // Current graph data
let originalGraphData = null;  // Original unfiltered graph data

// Initialize the application when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    initializeCytoscape();
    setupEventListeners();
    setupWebviewBridge();
    
    // Load demo data if available (for testing)
    loadDemoData();
});

/**
 * Initialize Cytoscape graph visualization
 */
function initializeCytoscape() {
    cy = cytoscape({
        container: document.getElementById('cytoscape'),
        
        style: [
            // Node styles
            {
                selector: 'node',
                style: {
                    'label': 'data(label)',
                    'text-valign': 'center',
                    'text-halign': 'center',
                    'background-color': '#4ec9b0',
                    'color': '#fff',
                    'text-outline-width': 2,
                    'text-outline-color': '#1e1e1e',
                    'font-size': '12px',
                    'width': 'label',
                    'height': 'label',
                    'padding': '10px',
                    'shape': 'round-rectangle',
                    'border-width': 2,
                    'border-color': '#3e3e42'
                }
            },
            
            // Edge styles
            {
                selector: 'edge',
                style: {
                    'width': 2,
                    'line-color': '#606060',
                    'target-arrow-color': '#606060',
                    'target-arrow-shape': 'triangle',
                    'curve-style': 'bezier',
                    'arrow-scale': 1.2
                }
            },
            
            // Node status styles
            {
                selector: '.implemented',
                style: {
                    'background-color': '#4ec9b0',
                    'border-color': '#3a9b8c'
                }
            },
            {
                selector: '.stub',
                style: {
                    'background-color': '#dcdcaa',
                    'border-color': '#b8b888'
                }
            },
            {
                selector: '.missing',
                style: {
                    'background-color': '#f48771',
                    'border-color': '#d06050'
                }
            },
            {
                selector: '.external',
                style: {
                    'background-color': '#808080',
                    'border-color': '#606060'
                }
            },
            
            // Highlighted styles
            {
                selector: '.highlighted',
                style: {
                    'border-width': 4,
                    'border-color': '#4ec9b0',
                    'z-index': 999
                }
            },
            {
                selector: '.dimmed',
                style: {
                    'opacity': 0.3
                }
            },
            {
                selector: 'edge.highlighted',
                style: {
                    'width': 3,
                    'line-color': '#4ec9b0',
                    'target-arrow-color': '#4ec9b0',
                    'z-index': 999
                }
            }
        ],
        
        layout: {
            name: 'dagre',
            rankDir: 'TB',
            nodeDimensionsIncludeLabels: true,
            animate: false,
            fit: true,
            padding: 50
        },
        
        wheelSensitivity: 0.2,
        minZoom: 0.1,
        maxZoom: 5
    });
    
    // Node click handler
    cy.on('tap', 'node', function(evt) {
        const node = evt.target;
        showNodeDetails(node);
        highlightConnections(node);
    });
    
    // Background click handler
    cy.on('tap', function(evt) {
        if (evt.target === cy) {
            hideSidebar();
            clearHighlights();
        }
    });
}

/**
 * Setup event listeners for UI controls
 */
function setupEventListeners() {
    // Layout selector
    document.getElementById('layout-select').addEventListener('change', (e) => {
        applyLayout(e.target.value);
    });
    
    // Filter input
    document.getElementById('filter-input').addEventListener('input', (e) => {
        filterGraph(e.target.value);
    });
    
    // View controls
    document.getElementById('fit-button').addEventListener('click', () => {
        cy.fit();
    });
    
    document.getElementById('reset-button').addEventListener('click', () => {
        resetView();
    });
    
    // Export controls
    document.getElementById('export-png').addEventListener('click', () => {
        exportPNG();
    });
    
    document.getElementById('export-json').addEventListener('click', () => {
        exportJSON();
    });
    
    // Sidebar close button
    document.getElementById('close-sidebar').addEventListener('click', () => {
        hideSidebar();
        clearHighlights();
    });
}

/**
 * Setup communication bridge with C++ webview
 */
function setupWebviewBridge() {
    // Listen for messages from C++
    if (window.cppBridge) {
        window.cppBridge.onMessage = (message) => {
            handleCppMessage(message);
        };
    }
}

/**
 * Handle messages from C++ backend
 */
function handleCppMessage(message) {
    try {
        const data = JSON.parse(message);
        
        switch (data.type) {
            case 'graph':
                loadGraphData(data.payload);
                break;
            case 'error':
                showError(data.message);
                break;
            case 'progress':
                showProgress(data.message, data.percentage);
                break;
            default:
                console.warn('Unknown message type:', data.type);
        }
    } catch (error) {
        console.error('Error handling C++ message:', error);
    }
}

/**
 * Send message to C++ backend
 */
function sendToCpp(type, payload) {
    if (window.cppBridge && window.cppBridge.postMessage) {
        window.cppBridge.postMessage(JSON.stringify({ type, payload }));
    }
}

/**
 * Load graph data from JSON
 */
function loadGraphData(data) {
    showLoading();
    
    try {
        graphData = data;
        originalGraphData = JSON.parse(JSON.stringify(data));  // Deep copy
        
        // Convert to Cytoscape format
        const elements = convertToCytoscapeFormat(data);
        
        // Update graph
        cy.elements().remove();
        cy.add(elements);
        
        // Apply layout
        applyLayout('dagre');
        
        // Update stats
        updateStats();
        
        hideLoading();
    } catch (error) {
        console.error('Error loading graph data:', error);
        showError('Failed to load graph data: ' + error.message);
    }
}

/**
 * Convert graph data to Cytoscape format
 */
function convertToCytoscapeFormat(data) {
    const elements = [];
    
    // Add nodes
    data.nodes.forEach((node, index) => {
        const status = getNodeStatus(node);
        elements.push({
            group: 'nodes',
            data: {
                id: 'node-' + index,
                label: node.name,
                name: node.name,
                file: node.file,
                line: node.line,
                status: status,
                isStub: node.isStub,
                isMissing: node.isMissing,
                isExternal: node.isExternal
            },
            classes: status
        });
    });
    
    // Add edges
    data.edges.forEach((edge, index) => {
        elements.push({
            group: 'edges',
            data: {
                id: 'edge-' + index,
                source: 'node-' + edge.from,
                target: 'node-' + edge.to
            }
        });
    });
    
    return elements;
}

/**
 * Get node status based on flags
 */
function getNodeStatus(node) {
    if (node.isMissing) return 'missing';
    if (node.isExternal) return 'external';
    if (node.isStub) return 'stub';
    return 'implemented';
}

/**
 * Apply layout to graph
 */
function applyLayout(layoutName) {
    const layouts = {
        'dagre': {
            name: 'dagre',
            rankDir: 'TB',
            nodeDimensionsIncludeLabels: true,
            animate: true,
            animationDuration: 500,
            fit: true,
            padding: 50
        },
        'breadthfirst': {
            name: 'breadthfirst',
            directed: true,
            animate: true,
            animationDuration: 500,
            fit: true,
            padding: 50
        },
        'circle': {
            name: 'circle',
            animate: true,
            animationDuration: 500,
            fit: true,
            padding: 50
        },
        'concentric': {
            name: 'concentric',
            concentric: function(node) {
                return node.degree();
            },
            levelWidth: function() {
                return 2;
            },
            animate: true,
            animationDuration: 500,
            fit: true,
            padding: 50
        },
        'grid': {
            name: 'grid',
            animate: true,
            animationDuration: 500,
            fit: true,
            padding: 50
        }
    };
    
    const layout = cy.layout(layouts[layoutName] || layouts['dagre']);
    layout.run();
}

/**
 * Filter graph based on search query
 */
function filterGraph(query) {
    if (!query) {
        // Show all elements
        cy.elements().removeClass('hidden');
        cy.elements().style('display', 'element');
    } else {
        const lowerQuery = query.toLowerCase();
        
        // Hide all elements first
        cy.elements().style('display', 'none');
        
        // Show matching nodes and their edges
        cy.nodes().forEach(node => {
            const name = node.data('name').toLowerCase();
            const file = node.data('file').toLowerCase();
            
            if (name.includes(lowerQuery) || file.includes(lowerQuery)) {
                node.style('display', 'element');
                node.connectedEdges().style('display', 'element');
                node.connectedEdges().connectedNodes().style('display', 'element');
            }
        });
    }
    
    updateStats();
}

/**
 * Show node details in sidebar
 */
function showNodeDetails(node) {
    const data = node.data();
    
    document.getElementById('detail-name').textContent = data.name;
    document.getElementById('detail-file').textContent = data.file;
    document.getElementById('detail-line').textContent = data.line;
    document.getElementById('detail-status').textContent = data.status;
    
    // Get callers and callees
    const callers = [];
    const callees = [];
    
    node.connectedEdges().forEach(edge => {
        if (edge.target().id() === node.id()) {
            callers.push(edge.source().data('name'));
        } else {
            callees.push(edge.target().data('name'));
        }
    });
    
    // Update lists
    updateList('detail-calls', callees);
    updateList('detail-callers', callers);
    
    // Show sidebar
    document.getElementById('sidebar').classList.remove('hidden');
}

/**
 * Update a detail list
 */
function updateList(elementId, items) {
    const list = document.getElementById(elementId);
    list.innerHTML = '';
    
    if (items.length === 0) {
        const li = document.createElement('li');
        li.textContent = 'None';
        li.style.color = '#808080';
        list.appendChild(li);
    } else {
        items.forEach(item => {
            const li = document.createElement('li');
            li.textContent = item;
            li.addEventListener('click', () => {
                // Find and select the node
                const targetNode = cy.nodes(`[name="${item}"]`).first();
                if (targetNode) {
                    targetNode.trigger('tap');
                }
            });
            list.appendChild(li);
        });
    }
}

/**
 * Hide sidebar
 */
function hideSidebar() {
    document.getElementById('sidebar').classList.add('hidden');
}

/**
 * Highlight connections for a node
 */
function highlightConnections(node) {
    // Clear previous highlights
    clearHighlights();
    
    // Dim all elements
    cy.elements().addClass('dimmed');
    
    // Highlight selected node and connections
    node.removeClass('dimmed').addClass('highlighted');
    node.connectedEdges().removeClass('dimmed').addClass('highlighted');
    node.connectedEdges().connectedNodes().removeClass('dimmed');
}

/**
 * Clear all highlights
 */
function clearHighlights() {
    cy.elements().removeClass('highlighted dimmed');
}

/**
 * Reset view to initial state
 */
function resetView() {
    document.getElementById('filter-input').value = '';
    filterGraph('');
    clearHighlights();
    hideSidebar();
    cy.fit();
}

/**
 * Update statistics display
 */
function updateStats() {
    const visibleNodes = cy.nodes(':visible');
    const visibleEdges = cy.edges(':visible');
    
    document.getElementById('node-count').textContent = `${visibleNodes.length} functions`;
    document.getElementById('edge-count').textContent = `${visibleEdges.length} calls`;
}

/**
 * Export graph as PNG
 */
function exportPNG() {
    const png = cy.png({
        output: 'blob',
        bg: '#1e1e1e',
        scale: 2,
        full: true
    });
    
    const link = document.createElement('a');
    link.href = URL.createObjectURL(png);
    link.download = 'codemap-graph.png';
    link.click();
}

/**
 * Export graph as JSON
 */
function exportJSON() {
    if (graphData) {
        const json = JSON.stringify(graphData, null, 2);
        const blob = new Blob([json], { type: 'application/json' });
        
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = 'codemap-graph.json';
        link.click();
    }
}

/**
 * Show loading indicator
 */
function showLoading() {
    document.getElementById('loading').classList.remove('hidden');
    document.getElementById('error').classList.add('hidden');
}

/**
 * Hide loading indicator
 */
function hideLoading() {
    document.getElementById('loading').classList.add('hidden');
}

/**
 * Show error message
 */
function showError(message) {
    document.getElementById('error-message').textContent = message;
    document.getElementById('error').classList.remove('hidden');
    document.getElementById('loading').classList.add('hidden');
}

/**
 * Show progress indicator
 */
function showProgress(message, percentage) {
    // Could enhance loading indicator with progress bar
    console.log(`Progress: ${message} (${percentage}%)`);
}

/**
 * Load demo data for testing
 */
function loadDemoData() {
    // Check if we're running in demo mode (no C++ backend)
    if (!window.cppBridge) {
        // Create some demo data
        const demoData = {
            nodes: [
                { name: 'main', file: 'main.cpp', line: 10, isStub: false, isMissing: false, isExternal: false },
                { name: 'parseFile', file: 'parser.cpp', line: 25, isStub: false, isMissing: false, isExternal: false },
                { name: 'buildGraph', file: 'graph.cpp', line: 40, isStub: false, isMissing: false, isExternal: false },
                { name: 'exportJSON', file: 'json.cpp', line: 15, isStub: false, isMissing: false, isExternal: false },
                { name: 'TODO_validate', file: 'validator.cpp', line: 5, isStub: true, isMissing: false, isExternal: false },
                { name: 'missingFunc', file: '', line: 0, isStub: false, isMissing: true, isExternal: false },
                { name: 'std::cout', file: '', line: 0, isStub: false, isMissing: false, isExternal: true }
            ],
            edges: [
                { from: 0, to: 1 },
                { from: 0, to: 2 },
                { from: 1, to: 4 },
                { from: 2, to: 3 },
                { from: 2, to: 5 },
                { from: 3, to: 6 }
            ]
        };
        
        // Load demo data after a short delay
        setTimeout(() => {
            loadGraphData(demoData);
        }, 500);
    }
}