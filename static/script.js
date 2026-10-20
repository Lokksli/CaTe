const dailyAverage = document.getElementById('dayAverageCheckbox');
const applyButton = document.getElementById('applyButton');

const startSlider = document.getElementById('startSlider');
const endSlider = document.getElementById('endSlider');

const highestTempElement = document.getElementById('highest_temp');
const lowestTempElement = document.getElementById('lowest_temp');

const hottestMonthElement = document.getElementById('hottest_month');
const coldestMonthElement = document.getElementById('coldest_month');


function updateYears() {
    let start = Number(startSlider.value);
    let end = Number(endSlider.value);
    console.log(endSlider.value)

    if (start > end) {
        if (document.activeElement === startSlider) {
            endSlider.value = start;
            end = start;
        } else {
            startSlider.value = end;
            start = end;
        }
    }


    document.getElementById('yearStart').textContent = start;
    document.getElementById('yearEnd').textContent = end;
    console.log(start);
    console.log(end);
}

startSlider.addEventListener('input', updateYears);
endSlider.addEventListener('input', updateYears);




applyButton.addEventListener('click', async () => {
    const res = await fetch('/daily_average_temperature', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            daily_average: dailyAverage.checked,
            start_year: startSlider.value,
            end_year: endSlider.value
        })
    });

    const data = await res.json();

    if (res.ok) {
        document.getElementById('graph').innerHTML =
            `<iframe src="${data.url}"></iframe>`;

        highestTempElement.textContent =
            `Highest range temperature: ${data.stats.highest} °C (${data.stats.highest_date})`;
        lowestTempElement.textContent =
            `Lowest range temperature:  ${data.stats.lowest} °C (${data.stats.lowest_date})`;
    } else {
        alert(data.error || 'Something went wrong');
    }
});