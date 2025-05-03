/**
 * Creates a pie chart for displaying score data
 * @param {string} elementId - The ID of the element to render the chart in
 * @param {Array} data - The data for the pie chart
 * @param {string} title - The title of the chart
 */
function createPieChart(elementId, data, title) {
  if (!data || data.length === 0) {
    document.getElementById(elementId).innerHTML = "<p>No data available</p>";
    return;
  }

  // Canvas setup
  const container = document.getElementById(elementId);
  container.innerHTML = "";

  const canvas = document.createElement("canvas");
  canvas.width = container.offsetWidth;
  canvas.height = container.offsetHeight;
  container.appendChild(canvas);

  const ctx = canvas.getContext("2d");
  const centerX = canvas.width / 2;
  const centerY = canvas.height / 2;
  const radius = Math.min(centerX, centerY) * 0.8;

  // Calculate total for percentages
  const total = data.reduce((sum, item) => sum + parseFloat(item.value), 0);

  // Define colors for the pie slices
  const colors = [
    "#4285F4", // Google Blue
    "#EA4335", // Google Red
    "#FBBC05", // Google Yellow
    "#34A853", // Google Green
    "#8A2BE2", // BlueViolet
    "#FF7F50", // Coral
    "#6495ED", // CornflowerBlue
    "#DC143C", // Crimson
    "#FF8C00", // DarkOrange
    "#9932CC", // DarkOrchid
  ];

  // Draw pie chart
  let startAngle = 0;
  let colorIndex = 0;

  // Draw title
  ctx.font = "bold 16px Arial";
  ctx.fillStyle = "#333";
  ctx.textAlign = "center";
  ctx.fillText(title, centerX, 30);

  // Create legend data
  const legendItems = [];

  // Draw pie slices
  data.forEach((item, index) => {
    const value = parseFloat(item.value);
    const sliceAngle = (value / total) * 2 * Math.PI;

    // Draw slice
    ctx.beginPath();
    ctx.moveTo(centerX, centerY);
    ctx.arc(centerX, centerY, radius, startAngle, startAngle + sliceAngle);
    ctx.closePath();

    const color = colors[colorIndex % colors.length];
    ctx.fillStyle = color;
    ctx.fill();

    // Add slice border
    ctx.lineWidth = 2;
    ctx.strokeStyle = "#fff";
    ctx.stroke();

    // Calculate position for the label (middle of the slice)
    const midAngle = startAngle + sliceAngle / 2;
    const labelRadius = radius * 0.7;
    const labelX = centerX + labelRadius * Math.cos(midAngle);
    const labelY = centerY + labelRadius * Math.sin(midAngle);

    // Draw percentage label if slice is big enough
    const percentage = Math.round((value / total) * 100);
    if (percentage > 5) {
      ctx.font = "bold 14px Arial";
      ctx.fillStyle = "#fff";
      ctx.textAlign = "center";
      ctx.textBaseline = "middle";
      ctx.fillText(`${percentage}%`, labelX, labelY);
    }

    // Store legend information
    legendItems.push({
      color: color,
      label: item.label,
      value: value,
      percentage: percentage,
    });

    // Increment for next slice
    startAngle += sliceAngle;
    colorIndex++;
  });

  // Draw legend
  const legendX = 20;
  let legendY = canvas.height - data.length * 25 - 20;

  legendItems.forEach((item) => {
    // Draw color box
    ctx.fillStyle = item.color;
    ctx.fillRect(legendX, legendY, 20, 20);

    // Draw border around color box
    ctx.strokeStyle = "#333";
    ctx.lineWidth = 1;
    ctx.strokeRect(legendX, legendY, 20, 20);

    // Draw text
    ctx.font = "14px Arial";
    ctx.fillStyle = "#333";
    ctx.textAlign = "left";
    ctx.textBaseline = "middle";
    ctx.fillText(
      `${item.label}: ${item.value} (${item.percentage}%)`,
      legendX + 30,
      legendY + 10
    );

    legendY += 25;
  });
}

/**
 * Creates a bar chart for displaying score data
 * @param {string} elementId - The ID of the element to render the chart in
 * @param {Array} data - The data for the bar chart
 * @param {string} title - The title of the chart
 */
function createBarChart(elementId, data, title) {
  if (!data || data.length === 0) {
    document.getElementById(elementId).innerHTML = "<p>No data available</p>";
    return;
  }

  // Canvas setup
  const container = document.getElementById(elementId);
  container.innerHTML = "";

  const canvas = document.createElement("canvas");
  canvas.width = container.offsetWidth;
  canvas.height = container.offsetHeight;
  container.appendChild(canvas);

  const ctx = canvas.getContext("2d");

  // Chart dimensions
  const chartLeft = 70;
  const chartTop = 50;
  const chartRight = canvas.width - 30;
  const chartBottom = canvas.height - 50;
  const chartWidth = chartRight - chartLeft;
  const chartHeight = chartBottom - chartTop;

  // Find maximum value for scaling
  const maxValue = Math.max(...data.map((item) => parseFloat(item.value)));
  const roundedMax = Math.ceil(maxValue / 10) * 10; // Round up to nearest 10

  // Bar properties
  const barCount = data.length;
  const barWidth = Math.min(60, chartWidth / barCount - 10);
  const barSpacing = (chartWidth - barWidth * barCount) / (barCount + 1);

  // Draw title
  ctx.font = "bold 16px Arial";
  ctx.fillStyle = "#333";
  ctx.textAlign = "center";
  ctx.fillText(title, canvas.width / 2, 30);

  // Draw y-axis
  ctx.beginPath();
  ctx.moveTo(chartLeft, chartTop);
  ctx.lineTo(chartLeft, chartBottom);
  ctx.strokeStyle = "#333";
  ctx.stroke();

  // Draw x-axis
  ctx.beginPath();
  ctx.moveTo(chartLeft, chartBottom);
  ctx.lineTo(chartRight, chartBottom);
  ctx.stroke();

  // Draw y-axis labels and grid lines
  const yLabelCount = 5;
  for (let i = 0; i <= yLabelCount; i++) {
    const value = roundedMax * (i / yLabelCount);
    const y = chartBottom - chartHeight * (i / yLabelCount);

    // Draw grid line
    ctx.beginPath();
    ctx.moveTo(chartLeft, y);
    ctx.lineTo(chartRight, y);
    ctx.strokeStyle = "#ddd";
    ctx.stroke();

    // Draw label
    ctx.font = "12px Arial";
    ctx.fillStyle = "#333";
    ctx.textAlign = "right";
    ctx.textBaseline = "middle";
    ctx.fillText(value.toFixed(0), chartLeft - 10, y);
  }

  // Draw bars and x-axis labels
  data.forEach((item, index) => {
    const value = parseFloat(item.value);
    const x = chartLeft + barSpacing + (barWidth + barSpacing) * index;
    const barHeight = (value / roundedMax) * chartHeight;
    const y = chartBottom - barHeight;

    // Draw bar
    ctx.fillStyle = "#4285F4";
    ctx.fillRect(x, y, barWidth, barHeight);

    // Draw bar border
    ctx.strokeStyle = "#333";
    ctx.lineWidth = 1;
    ctx.strokeRect(x, y, barWidth, barHeight);

    // Draw x-axis label (rotate if needed)
    ctx.save();
    ctx.translate(x + barWidth / 2, chartBottom + 10);

    // If label is too long, rotate it
    const label = item.label;
    if (label.length > 5) {
      ctx.rotate(Math.PI / 4);
      ctx.textAlign = "right";
    } else {
      ctx.textAlign = "center";
    }

    ctx.font = "12px Arial";
    ctx.fillStyle = "#333";
    ctx.textBaseline = "top";
    ctx.fillText(label, 0, 0);
    ctx.restore();

    // Draw value on top of the bar
    ctx.font = "12px Arial";
    ctx.fillStyle = "#333";
    ctx.textAlign = "center";
    ctx.textBaseline = "bottom";
    ctx.fillText(value.toFixed(1), x + barWidth / 2, y - 5);
  });
}
