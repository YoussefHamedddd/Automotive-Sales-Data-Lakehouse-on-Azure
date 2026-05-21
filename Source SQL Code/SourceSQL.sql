CREATE TABLE Source_cars_data (
    Branch_ID VARCHAR(200),
    Dealer_ID VARCHAR(200),
    Model_ID VARCHAR(200),
    Revenue BIGINT,
    Units_Sold BIGINT,
    Date_ID VARCHAR(200),
    Day INT,
    Month INT,
    Year INT,
    BranchName VARCHAR(200),
    DealerName VARCHAR(200),
    Product_Name VARCHAR(200)
);

CREATE TABLE water_mark (
    last_load VARCHAR(200)
);


CREATE PROCEDURE UpdateWatermarkTable
    @LastLoad VARCHAR(200)
AS
BEGIN
    BEGIN TRANSACTION;

    UPDATE water_mark
    SET last_load = @LastLoad;

    COMMIT TRANSACTION;
END;