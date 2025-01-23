# Human Resources Data Analysis

This repository contains a **Power BI project** analysing the **Human Resources dataset** from [Kaggle](https://www.kaggle.com/datasets/rhuebner/human-resources-data-set/data). The data has been cleaned, normalised into a star schema, and analysed to provide insights into various aspects of employee retention, diversity, compensation, and satisfaction.

## Dataset Overview

The dataset contains employee information, including the following columns:

- **Employee ID**
- **Employee Name**
- **Department ID**
- **Department Name**
- **Position ID**
- **Position Name**
- **Salary**
- **Date of Hire**
- **Termination Date**
- **Employee Satisfaction Score**
- **Performance Rating**
- **Absenteeism**
- **Reason for Termination**

## Project Overview

This project uses Power BI to analyse the HR data. The dataset has been cleaned and transformed using **Power Query**, and then normalised into a **star schema** with a centralised **fact table** and **dimension tables** for improved data analysis.

### **Key Questions Addressed in the Analysis:**

1. **Is there a gender pay gap?**
   - Compare average salaries by gender to check for discrepancies in pay.

2. **Is the business 50:50 female to male?**
   - Analyse the gender ratio across the company.

3. **What is the attrition rate?**
   - Calculate the turnover rate and identify patterns of employee retention.

4. **What are the reasons for terminations?**
   - Explore the various reasons employees leave and identify trends in termination reasons.

5. **Are there any departments with high turnover?**
   - Investigate turnover rates by department and determine if some have significantly higher attrition.

6. **What is my average salary and salary range?**
   - Calculate the average salary and explore the salary distribution across different departments and positions.

7. **Does tenure correlate with salary?**
   - Analyse if longer employee tenure results in higher salaries.

8. **Are employees satisfied?**
   - Assess overall employee satisfaction and whether it varies by department, gender, or other factors.

## Data Cleaning and Transformation

The dataset was cleaned and transformed using **Power Query** in Power BI. Below are the key steps in the data cleaning and transformation process:

### 1. **Removing Duplicates**

- **Action**: There were no duplicates. I checked with Remove Rows > Remove Duplicates and viewing Column Distribution.

### 2. **Changed Data Types**

- **Action**: All data types were stored as text. Dates were converted to dates. Numerical values converted to integers / decimals. The date columns were stored as M/D/YY format so I converted using Locale "EN-GB".
  
### 3. **Handling Missing Values**

- **Action**: Some columns had missing values, such as `Manager_ID`. It was a single value so I replaced null with the relevant manager id number. This would be incorrect if there were different manager ids.

### 4. **Standardised Column Headers**

- **Action**: Some column headers had '_' for a space and others had no space. I added '_' to represent spaces for all headers and changed to lowercase for easier to write DAX measures.

### 5. **Normalisation (Star Schema)**

- **Action**: I needed to normalise the dataset as it was denormalised which lead to ineffiencies. I began by identifying **ID** columns and their corresponding **Name** columns (e.g., `employee_id`, `employee_name`, `department_id`, `department_name`).
  - **Steps**:
    1. Duplicated the table to preserve the original structure.
    2. Removed all columns except for the ID and Name columns to create individual dimension tables.
    3. Checked for duplicates and sorted the data by the ID column to ensure unique entries.

### 6. **Calculated Columns**

- **Action**: Created new columns to calculate employee tenure and other key metrics in the **Fact Table**

## Power BI Visualisations

Once the data was cleaned and normalised, I created several visualisations in Power BI to answer the key business questions:

### Key Dashboards and Reports:
1. **Human Resources Dashboard**:
   - Shows top line insights into our channels such as attrition, age, employee satisfaction, headcount, and tenure.
2. **Gender Equality Dashboard**: 
   - Measures the average salary and headcount by gender.
3. **Turnover Dashboard**:
   - Displays the attrition rate, reasons for termination, and turnover by department.
4. **Salary Dashboard**:
   - Shows the average salary, salary range, and comparisons across departments.

## How to Use This Project

1. **Clone this repository** to get access to the Power BI file and cleaned dataset.
2. Open the Power BI file (`human_resources.pbix`) in Power BI Desktop.
3. **Explore the interactive dashboards** and visualisations for insights on employee retention, compensation, satisfaction, and more.

---

## Licence

This project is licensed under the MIT Licence - see the [LICENSE.md](LICENSE.md) file for details.

