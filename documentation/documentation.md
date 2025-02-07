# Ignition Soda Bottling Analysis

## Project Overview

This dataset comes from a manufacturing company called **Ignition**, which produces soda bottles. The data includes **productivity & downtime records** for a soda bottling production line, including information on:

- Operators  
- Products  
- Start & end times  
- Downtime factors for each batch  

---

## **Stakeholder Questions**
The stakeholders posed several key questions for this analysis:

1. **What’s the current line efficiency?**  
   - Measured as **Total Time / Minimum Possible Time**  
   - Consider alternative efficiency metrics  

2. **Are any operators underperforming?**  
   - Identify operators with below-average efficiency  
   - Analyze fault rates specific to operator errors  

3. **What are the leading factors for downtime?**  
   - Breakdown of downtime causes per product  

4. **Do any operators struggle with specific types of operator errors?**  
   - Identify patterns in operator errors over time  

---

## **Line Efficiency Analysis**
**Line efficiency** is a crucial metric for manufacturing companies to assess operational effectiveness. The stakeholders want to measure efficiency using:  

$\[
\text{Line Efficiency} = \frac{\text{Total Time}}{\text{Minimum Possible Time}}
\]$

Additionally, multiple metrics could be calculated to provide a more comprehensive understanding of production efficiency.

---

## **Operator Performance Analysis**
To assess operator performance, I calculated the following key metrics:

### **1. Operator Efficiency Rate**
- Measures each operator’s **average efficiency** using the **Line Efficiency** formula above.
- **Ranking operators** based on efficiency.  
- Assumption: Since non-operator-related downtime should average out over time, large deviations can be attributed to the operator.  

### **2. Operator’s Fault Rate Average**
- **Definition:** Total time lost due to operator errors **only**.
- **Adjustment:** To prevent penalizing operators who work more, I normalize the fault rate by the sum of their minimum batch time.

$\[
\text{Fault Rate} = \frac{\text{Total Fault Time (Operator Errors Only)}}{\text{Total Minimum Batch Time Worked}}
\]$

### **3. Operator Total Volume Produced**
- Simply the total **number of bottles** each operator produced during the analyzed period.

---

## **Downtime Analysis**
### **1. Downtime Factors Per Product**
- Identifies the most frequent downtime causes.  
- Breaks down **downtime impact per product line** to detect patterns.  

### **2. Operator-Specific Errors**
#### **Operator Error / Time Worked**
- Helps determine if specific operators struggle with certain errors.  
- Each operator is assigned a count for each type of error they made.  
- Expressed as a **percentage of total time worked**.  

---

## **Data Transformation Process**
The first challenge was **reshaping the data** for proper analysis:

### **1. Converting Downtime Data to Long Format**
- The original dataset was in **wide format**, making it difficult to JOIN downtime factors with production data.  
- Used **Power Query in Excel** to **unpivot** columns and restructure the dataset.

### **2. Formatting Time Data**
- Ensured time values were stored in a **PostgreSQL-compatible format**.  
- Used Excel to extract and convert time values properly.

### **3. Formatting Date Values**
- Converted date fields to **standardized formats** for better integration with PostgreSQL.

### **4. Standardizing Volume Data**
- Removed units from volume values.  
- Ensured all values were converted to **integers** for analysis.  

### **5. Extract, Transform, Load (ETL)**
- **Extracted** data from Excel.  
- **Transformed** it into the correct formats.  
- **Loaded** it into a **PostgreSQL Database** for further analysis.  

---

## **SQL Queries**
All **SQL commands** used in this project can be found in the **`.SQL` file**.  
Each query is **commented** to explain its purpose and logic.

---

This document serves as a structured outline of the **Ignition Soda Bottling Analysis**, detailing the **data processing pipeline, key efficiency metrics, and operator performance evaluation**. 🚀
