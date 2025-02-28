## Subject: Key Findings, Trends & Next Steps from Fetch Data Analysis

## Introduction  
Hello Product / Business Manager,  

I’ve completed an in-depth analysis of Fetch’s transaction and user data, identifying key data quality issues, user trends, and business opportunities. Below is a summary of my findings and recommended next steps.  

---

## Key Data Quality Issues & Business Impact  
- **Missing Data (Birth Date, Gender, Language)** – Limits customer segmentation and targeting effectiveness.  
- **Duplicate Product Records** – Skews analytics, leading to incorrect insights and poor decision-making.  
- **Inconsistent Product Categorization** – Example: Hard Seltzers are misclassified as non-alcoholic, affecting analytics.  
- **Brand, Gender & Store Name Variations** – Causes inconsistent reporting and brand performance tracking.  
- **Data Format Issues in FINAL_QUANTITY** – Some sales records store `'zero'` as text instead of numeric `0`, leading to calculation errors in our analysis.
---

## Outstanding Questions  
1. What is the product hierarchy? How should we interpret and use the multi-level category system (`CATEGORY_1` to `CATEGORY_4`) for products?  
2. How should we handle placeholder birthdates (e.g., `"1970-01-01"`) in user data?
3. Is a new receipt ID assigned when a receipt is re-uploaded?    

---

## Key User Trend: Inactivity & Churn Risk  
- **50% of inactive users disengage within 30 days**, and **25% more stop engaging by 60 days**, indicating a critical **90-day churn risk window**.  
- **Actionable Insight:**  
  - Implement targeted engagement campaigns (discounts, notifications, reminders) within the first 30 days.  
  - Introduce loyalty programs or personalized incentives for users in the 31-90 day window to reduce churn and boost retention.  

---
## Additional Findings
**Top 5 Brands by Receipts Scanned Among Users 21+**
  1. DOVE
  2. NERDS CANDY
  3. COCA-COLA
  4. HERSHEY'S
  5. SOUR PATCH KIDS
- These brands demonstrate strong customer engagement. Fetch can explore potential brand partnerships and promotions.

**Leading Brand in the Dips & Salsa Category**
  - Tostitos is the leading brand based on revenue and sales volume.
  - Fetch can use this insight to recommend relevant promotions to users who frequently purchase from this category.

## Recommendations  
- **Improve Data Collection & Validation** – Work with the tech team to ensure accurate data extraction from receipts to prevent missing values.  
- **Standardize Brand, Gender & Store Name Variations** – To fix skewed reporting and improve analytics consistency.  
- **Clarify Product Hierarchy & Categorization Rules** – To correct misclassifications and improve product insights.  
---

## Conclusion  
I’ve attached a full report with detailed insights and visualizations for reference. I’m happy to connect and discuss this analysis further.  

Looking forward to your thoughts.  

Thanks,  
**Everlyn N. Musembi**  
