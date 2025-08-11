const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// GPU pricing (per hour)
const GPU_COSTS = {
  'nvidia-t4': { onDemand: 0.526, spot: 0.158 },
  'nvidia-v100': { onDemand: 2.48, spot: 0.74 },
  'nvidia-a100': { onDemand: 3.06, spot: 0.92 }
};

// Simulated data
let allocations = [];
let totalSpend = 2453.67;
let monthlyBudget = 10000;

// GPU availability
let gpuInventory = {
  'nvidia-t4': { total: 8, available: 5 },
  'nvidia-v100': { total: 4, available: 2 },
  'nvidia-a100': { total: 2, available: 1 }
};

// Dashboard endpoint
app.get('/api/dashboard', (req, res) => {
  const utilizationPercent = ((monthlyBudget - (monthlyBudget - totalSpend)) / monthlyBudget * 100).toFixed(1);
  res.json({
    gpuInventory,
    allocations: allocations.slice(-10),
    costMetrics: {
      currentSpend: totalSpend,
      monthlyBudget,
      utilizationPercent,
      projectedMonthly: totalSpend * 1.3,
      daysUntilLimit: Math.floor((monthlyBudget - totalSpend) / (totalSpend / new Date().getDate()))
    },
    gpuUtilization: {
      't4': Math.floor((3/8) * 100),
      'v100': Math.floor((2/4) * 100),
      'a100': Math.floor((1/2) * 100)
    }
  });
});

// Budget check endpoint
app.get('/api/budget/check', (req, res) => {
  const { gpuCount, hours, gpuType = 'nvidia-t4' } = req.query;
  const estimatedCost = GPU_COSTS[gpuType].onDemand * gpuCount * hours;
  const budgetRemaining = monthlyBudget - totalSpend;
  
  res.json({
    approved: estimatedCost < budgetRemaining * 0.1, // Max 10% of remaining budget
    estimatedCost,
    budgetRemaining,
    message: estimatedCost < budgetRemaining * 0.1 ? 'Budget approved' : 'Requires approval'
  });
});

// Allocation endpoint
app.post('/api/allocate', (req, res) => {
  const { name, framework, gpuCount, maxHours, priority, gpuType = 'nvidia-t4' } = req.body;
  
  if (gpuInventory[gpuType].available < gpuCount) {
    return res.status(400).json({ error: 'Insufficient GPU resources' });
  }
  
  const allocation = {
    allocationId: `alloc-${Date.now()}`,
    name,
    framework,
    gpuType,
    gpuCount,
    maxHours,
    priority,
    estimatedCost: (GPU_COSTS[gpuType].onDemand * gpuCount * maxHours).toFixed(2),
    status: 'active',
    timestamp: new Date().toISOString()
  };
  
  allocations.push(allocation);
  gpuInventory[gpuType].available -= gpuCount;
  totalSpend += parseFloat(allocation.estimatedCost);
  
  res.json(allocation);
});

// Model cost endpoint
app.get('/api/model/:name', (req, res) => {
  res.json({
    modelName: req.params.name,
    dailyCost: 45.67,
    monthlyCost: 1370.10,
    gpuHours: 87,
    apiCalls: 125432
  });
});

// Serve dashboard
app.get('/', (req, res) => {
  res.sendFile(__dirname + '/public/index.html');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`GPU Cost Tracker running on port ${PORT}`);
});