USE dev_HealthConnect_refined;
GO

SELECT
    Claim_Year,
    Total_Claim_Amount_Paid,
    Number_of_Claims_Processed,
    Average_Claim_Amount_Paid
FROM refined_dw.vw_KPI_01_Yearly_Claim_Trend
ORDER BY Claim_Year;
GO