// Function to create a pie chart for scores
function createPieChart(canvasId, data, labels, title) {
  const ctx = document.getElementById(canvasId).getContext("2d");
  const colors = [
    "#FF6384",
    "#36A2EB",
    "#FFCE56",
    "#4BC0C0",
    "#9966FF",
    "#FF9F40",
    "#C9CBCF",
    "#7CFC00",
    "#00CED1",
    "#FF7F50",
  ];

  const chartData = {
    datasets: [
      {
        data: data,
        backgroundColor: colors.slice(0, data.length),
      },
    ],
    labels: labels,
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    title: {
      display: true,
      text: title,
      fontSize: 16,
    },
    legend: {
      position: "bottom",
    },
  };

  new Chart(ctx, {
    type: "pie",
    data: chartData,
    options: options,
  });
}

// Function to create a bar chart for scores
function createBarChart(canvasId, data, labels, title, ylabel) {
  const ctx = document.getElementById(canvasId).getContext("2d");
  const colors = [
    "#FF6384",
    "#36A2EB",
    "#FFCE56",
    "#4BC0C0",
    "#9966FF",
    "#FF9F40",
    "#C9CBCF",
    "#7CFC00",
    "#00CED1",
    "#FF7F50",
  ];

  const chartData = {
    labels: labels,
    datasets: [
      {
        label: title,
        data: data,
        backgroundColor: colors.slice(0, data.length),
      },
    ],
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      yAxes: [
        {
          ticks: {
            beginAtZero: true,
          },
          scaleLabel: {
            display: true,
            labelString: ylabel,
          },
        },
      ],
    },
    title: {
      display: true,
      text: title,
      fontSize: 16,
    },
  };

  new Chart(ctx, {
    type: "bar",
    data: chartData,
    options: options,
  });
}

// Function to create a line chart for performance over time
function createLineChart(canvasId, data, labels, title, ylabel) {
  const ctx = document.getElementById(canvasId).getContext("2d");
  const colors = [
    "#FF6384",
    "#36A2EB",
    "#FFCE56",
    "#4BC0C0",
    "#9966FF",
    "#FF9F40",
    "#C9CBCF",
    "#7CFC00",
    "#00CED1",
    "#FF7F50",
  ];

  // Create datasets for each subject
  const datasets = [];
  const subjectData = {};

  // Group data by subject
  for (let i = 0; i < data.length; i++) {
    const subject = labels[i];
    if (!subjectData[subject]) {
      subjectData[subject] = [];
    }
    subjectData[subject].push(data[i]);
  }

  // Create a dataset for each subject
  let colorIndex = 0;
  for (const subject in subjectData) {
    datasets.push({
      label: subject,
      data: subjectData[subject],
      borderColor: colors[colorIndex % colors.length],
      backgroundColor: "transparent",
      pointBackgroundColor: colors[colorIndex % colors.length],
      pointRadius: 5,
    });
    colorIndex++;
  }

  const chartData = {
    labels: Object.keys(subjectData[Object.keys(subjectData)[0]]).map(
      (_, i) => i + 1
    ),
    datasets: datasets,
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      yAxes: [
        {
          ticks: {
            beginAtZero: true,
          },
          scaleLabel: {
            display: true,
            labelString: ylabel,
          },
        },
      ],
      xAxes: [
        {
          scaleLabel: {
            display: true,
            labelString: "Quiz Number",
          },
        },
      ],
    },
    title: {
      display: true,
      text: title,
      fontSize: 16,
    },
  };

  new Chart(ctx, {
    type: "line",
    data: chartData,
    options: options,
  });
}
