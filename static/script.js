const dailyAverage = document.getElementById('dayAverageCheckbox');
const applyButton = document.getElementById('applyButton');

const startSlider = document.getElementById('startSlider');
const endSlider = document.getElementById('endSlider');

const startSliderComparison = document.getElementById('startSliderComparison');
const endSliderComparison = document.getElementById('endSliderComparison');

const highestTempElement = document.getElementById('highest_temp');
const lowestTempElement = document.getElementById('lowest_temp');

const hottestMonthElement = document.getElementById('hottest_month');
const coldestMonthElement = document.getElementById('coldest_month'); 

const highestTempComparisonElement = document.getElementById('highest_temp_comparison');
const lowestTempComparisonElement = document.getElementById('lowest_temp_comparison');

const hottestMonthComparisonElement = document.getElementById('hottest_month_comparison');
const coldestMonthComparisonElement = document.getElementById('coldest_month_comparison'); 


const applyButtonComparison = document.getElementById('applyButtonComparison')
const container = document.querySelector('.container'); 
const compareDailyAverage = document.getElementById('compareDayAverageCheckbox');




function updateYears() { // Updating slider
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


function updateYearsComparison() { // Updating comparison slider
    let start = Number(startSliderComparison.value);
    let end = Number(endSliderComparison.value);
    console.log(endSliderComparison.value)

    if (start > end) {
        if (document.activeElement === startSliderComparison) {
            endSliderComparison.value = start;
            end = start;
        } else {
            startSliderComparison.value = end;
            start = end;
        }
    }


    document.getElementById('yearStartComparison').textContent = start;
    document.getElementById('yearEndComparison').textContent = end;
    console.log(start);
    console.log(end);
}

startSliderComparison.addEventListener('input', updateYearsComparison);
endSliderComparison.addEventListener('input', updateYearsComparison);



applyButton.addEventListener('click', async () => {             // Function for API request to flask on pressing button
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
        container.classList.remove('compare-mode');
        document.getElementById('firstGraph').src = data.url;
        document.getElementById('secondGraph').removeAttribute('src');
        highestTempElement.textContent =
            `Highest range temperature: ${data.stats.highest} °C (${data.stats.highest_date})`;
        lowestTempElement.textContent =
            `Lowest range temperature:  ${data.stats.lowest} °C (${data.stats.lowest_date})`;
        hottestMonthElement.textContent =
            `Hottest month: ${data.stats.hottest_month} °C (${data.stats.hottest_month_date})`;
        coldestMonthElement.textContent =
            `Coldest month: ${data.stats.coldest_month} °C (${data.stats.coldest_month_date})`;
    } else {
        alert(data.error || 'Something went wrong');
    }
});

applyButtonComparison.addEventListener('click', async () => {
    const res = await fetch('/compare_years', {
        method: 'POST', 
        headers: {
            'Content-Type': 'application/json'
        }, 
        body: JSON.stringify({
            daily_average: compareDailyAverage.checked,
            start_year_comparison: startSliderComparison.value,
            end_year_comparison: endSliderComparison.value
        })
    });

    const data = await res.json(); 

    if (res.ok) {
        console.log(`${data.url_start_year}`)
        container.classList.add('compare-mode');  
        document.getElementById('firstGraph').src = data.url_start_year;
        document.getElementById('secondGraph').src = data.url_end_year;
        highestTempComparisonElement.textContent =
            `Highest range temperature: ${data.stats.highest} °C (${data.stats.highest_date})`;
        lowestTempComparisonElement.textContent =
            `Lowest range temperature:  ${data.stats.lowest} °C (${data.stats.lowest_date})`;
        hottestMonthComparisonElement.textContent =
            `Hottest month: ${data.stats.hottest_month} °C (${data.stats.hottest_month_date})`;
        coldestMonthComparisonElement.textContent =
            `Coldest month: ${data.stats.coldest_month} °C (${data.stats.coldest_month_date})`;
    }


})