*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.
...

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.PDF
Library             RPA.Tables
Library             RPA.Archive
Library             RPA.FileSystem
Library             RPA.RobotLogListener


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Download the Excel file
    Open the robot order website
    Fill the order using data from Excel file
    Create a ZIP file
    Close the browser


*** Keywords ***
Open the robot order website
    # ToDo: Implement your keyword here
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    # Click Button    OK

Download the Excel file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Fill the order using data from Excel file
    ${orders}=    Read table from CSV    orders.csv    header=True

    FOR    ${order}    IN    @{orders}
        Fill the order for one robot    ${order}
    END

Fill the order for one robot
    [Arguments]    ${order}
    # Set Selenium Speed    0.2 sec
    Click Button    OK
    Select From List By Value    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    class:form-control    ${order}[Legs]
    Input Text    address    ${order}[Address]
    Click Button    order
    Run Keyword And Continue On Failure    Click Button    order
    Run Keyword And Continue On Failure    Click Button    order
    Run Keyword And Continue On Failure    Click Button    order
    Store the order receipt as a PDF file    ${order}
    Take a screenshot of the robot image    ${order}
    Embed the robot screenshot to the receipt PDF file    ${order}
    Click Button    Order another robot

Store the order receipt as a PDF file
    [Arguments]    ${order}
    Wait Until Element Is Visible    id:receipt
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}receipts${/}receipt${order}[Order number].pdf

Take a screenshot of the robot image
    [Arguments]    ${order}
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}receipts${/}receipt${order}[Order number].jpg

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${order}
    Open Pdf    ${OUTPUT_DIR}${/}receipts${/}receipt${order}[Order number].pdf

    ${image_file_path}=    Set Variable    ${OUTPUT_DIR}${/}receipts${/}receipt${order}[Order number].jpg
    ${pdf_file_path}=    set Variable    ${OUTPUT_DIR}${/}receipts${/}receipt${order}[Order number].pdf

    ${list}=    Create List
    ...    ${OUTPUT_DIR}${/}receipts${/}receipt${order}[Order number].pdf
    ...    ${OUTPUT_DIR}${/}receipts${/}receipt${order}[Order number].jpg
    Add Files To Pdf    ${list}    ${pdf_file_path}
    Close Pdf    ${pdf_file_path}
    Remove File    ${OUTPUT_DIR}${/}receipts${/}receipt${order}[Order number].jpg

Create a ZIP file
    ${zip_file}=    Set Variable    ${OUTPUT_DIR}${/}receipts.zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    ${zip_file}

Close the browser
    Close Browser
