async function updateDashboard() {
    const response = await fetch('/api/dashboard');
    const data = await response.json();
    
    // Update metrics
    document.getElementById('spend').textContent = data.costMetrics.currentSpend.toFixed(2);
    document.getElementById('budget').textContent = data.costMetrics.monthlyBudget;
    document.getElementById('budget-bar').style.width = `${data.costMetrics.utilizationPercent}%`;
    document.getElementById('active-count').textContent = data.allocations.length;
    
    // GPU Availability
    const gpuHtml = Object.entries(data.gpuInventory).map(([type, info]) => 
        `<div style="margin: 10px 0;">
            <div style="display: flex; justify-content: space-between;">
                <span>${type}</span>
                <span>${info.available}/${info.total}</span>
            </div>
            <div class="gpu-bar">
                <div class="gpu-fill" style="width: ${(info.available/info.total)*100}%"></div>
            </div>
        </div>`
    ).join('');
    document.getElementById('gpu-availability').innerHTML = gpuHtml;
    
    // Recent Allocations
    const allocHtml = data.allocations.map(a => 
        `<div class="allocation-item">
            <div>
                <strong>${a.name}</strong><br>
                <span style="font-size: 0.85em; color: #8892b0;">${a.gpuType} • ${a.gpuCount} GPUs</span>
            </div>
            <span class="status active">$${a.estimatedCost}</span>
        </div>`
    ).join('');
    document.getElementById('allocations').innerHTML = allocHtml || '<p style="color: #8892b0;">No active allocations</p>';
    
    // Utilization Chart
    const ctx = document.getElementById('utilChart').getContext('2d');
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: ['T4', 'V100', 'A100'],
            datasets: [{
                label: 'GPU Utilization %',
                data: [data.gpuUtilization.t4, data.gpuUtilization.v100, data.gpuUtilization.a100],
                backgroundColor: ['#667eea', '#764ba2', '#f093fb']
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                y: { beginAtZero: true, max: 100, ticks: { color: '#8892b0' } },
                x: { ticks: { color: '#8892b0' } }
            }
        }
    });
}

updateDashboard();
setInterval(updateDashboard, 5000);