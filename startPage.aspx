<!--
FILE          : startPage.aspx
PROJECT       : Web Design and Development Assignment 6
PROGRAMMER    : Bilal Syed
FIRST VERSION : 2024-12-04
DESCRIPTION   : This file contains all the client sided code for a text editor web application. It 
                includes both the html content of the website and the jQueries that contain the
                requests to the server side. The queries also handle the response received from
                the server side and present the appropriate information to the user according to 
                the response received.
-->

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="startPage.aspx.cs" Inherits="WDD_A6.startPage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link rel="stylesheet" type="text/css" href="styles.css"/>
    <script src="<%= ResolveUrl("~/Scripts/jquery-3.7.1.min.js") %>"></script>
    <script type="text/javascript">

        //global variable to keep track of the currently opened file
        var openedFile = "";

        //this jQuery makes an ajax call whenever the page finishes loading
        $(document).ready(function ()
        {
            //ajax call
            $.ajax({
                //the following 4 lines are the request header which is sent to the server, it does not send any data because
                //the purpose with this query is only receive data to populate the dropdown list
                type: "POST",
                url: "startPage.aspx/DirectoryContents",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                //the following code occurs only if the response is received successfully
                success: function (response) {
                    let files = $.parseJSON(response.d);  //parse the json data sent in the response and store it in a variable
                    let fileDropDown = $("#filesList");   //get the select element and store it in a variable

                    fileDropDown.empty();   //empty out the select element so that it has no options

                    //if the MyFiles folder contains files
                    if (files.fileNames.length > 0) {
                        fileDropDown.append('<option value="empty">New File</option>');  //make the first option in the select element a "New File" option

                        //loop through the array of files names received from the server
                        for (let i = 0; i < files.fileNames.length; i++) {
                            //add an option to the select element for the current file in the array
                            fileDropDown.append(`<option value="${files.fileNames[i]}">${files.fileNames[i]}</option>`);
                        }
                    }
                    //if the MyFiles folder is empty
                    else {
                        fileDropDown.append('<option value="empty">New File</option>');
                    }
                },
                //the following code only occurs if the response is not received successfully
                error: function () {
                    //give an alert that the response was not received
                    alert("Error. Response not received.");
                }

            });
        });

        //this jQuery makes an ajax call whenever the openFileBtn button is clicked
        $(document).on('click', '#openFileBtn', function () {
            let file = $("#filesList").val();                  //make a variable to represent the value of the current selected option from the select element,
                                                               //this value is the file selected by the user to be opened
            openedFile = file;                                 //store the name of the file selected by the user in the openedFile global
            let textContent = $("#textEditSpace").val();       //make a variable to represent text currently in the edit space

            //if the user has selected an actual file name from the dropdown list
            if (file !== "empty") {
                var requestData = { fileName: file };         //set a variable equal to the request data to be sent to the server, in this case
                                                              //the file name selected by user is being sent to the server
                var fileName = JSON.stringify(requestData);   //convert the request data into a JSON string

                //ajax call
                $.ajax({
                    //the following 4 lines are the request header which is sent to the server, the data sent to the 
                    //server is the file name selected by the user
                    type: "POST",
                    url: "startPage.aspx/GetFileContents",
                    data: fileName,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    //the following code occurs only if the response is received successfully
                    success: function (response) {
                        let contents = $.parseJSON(response.d);      //make a variable to represent the parsed JSON response data sent by the server
                                                                     //the data sent by the server is the contents of the file selected by the user
                        $("#textEditSpace").val(contents.contents);  //display the contents of the file to the user in the text edit space
                    },
                    //the following code occurs only if the response is not received successfully
                    error: function () {
                        //give an alert that the response was not received
                        alert("Error. Response not received.");
                    }
                });
            }
            //if the user has selected the "New File" option then the text edit space is cleared out
            else {
                $("#textEditSpace").val("");
            }
        });

        //this jQuery maxes an ajax call when saveBtn button is clicked
        $(document).on('click', '#saveBtn', function () {
            let textContent = $("#textEditSpace").val();                              //make a variable to represent the text currently in the text edit space

            var requestData = { fileName: openedFile, fileContents: textContent };    //store the name of the currently opened file and the text edit space
                                                                                      //content in JSON format in a variable, this will be sent to the server
            var requestJson = JSON.stringify(requestData)                             //convert the data to be sent to the server into a JSON string and store
                                                                                      //it in a variable

            //if an actual file in the MyFiles directory is currently opened
            if (openedFile !== "empty" && openedFile !== "") {
                //ajax call
                $.ajax({
                    //the following 4 lines are the request header which is sent to the server, the data sent to the
                    //server is the name of the file currently opened and the contents of the text edit space
                    type: "POST",
                    url: "startPage.aspx/SaveFileContentsToCurrent",
                    data: requestJson,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    //the following code occurs only if the response is received successfully
                    success: function (response) {
                        let message = $.parseJSON(response.d);      //make a variable to represent the parsed JSON response data 
                        alert(message.status);                      //display the status message received from the response in an alert
                    },
                    //the following code occurs only if the response is not received successfully
                    error: function () {
                        //give an alert that the response was not received
                        alert("Error. Response not received.");
                    }
                });
            }
            //if no file in the MyFiles directory is currently opened then display an alert that the user must make a file using "Save As"
            else {
                alert("If you want to create a new file you must enter a new name and click the \"Save As\" button.");
            }
        });

        //this jQuery makes an ajax call when saveAsBtn is clicked
        $(document).on('click', '#saveAsBtn', function () {
            let file = $("#fileNameInput").val();            //make a variable to represent the new file name that the user inputted
            let textContent = $("#textEditSpace").val();     //make a veriable to represent the text currently in the text edit space
            let fileDropDown = $("#filesList");              //make a variable to represent the dropdown list containing all file names

            var requestData = { fileName: file, fileContents: textContent };   //store the new file name inputted by the user and the text edit space
                                                                               //content in JSON format in a variable, this will be sent to the server
            var requestJson = JSON.stringify(requestData)                      //convert the data to be sent to the server into a JSON string and store
                                                                               //it in a variable

            //ajax call
            $.ajax({
                //the following 4 lines are the request header which is sent to the server, the data sent to the
                //server is the new file name inputted by the user and the contents of the text edit space
                type: "POST",
                url: "startPage.aspx/SaveFileContentsAs",
                data: requestJson,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                //the following code occurs only if the response is received successfully
                success: function (response) {
                    let message = $.parseJSON(response.d);    //make a variable to represent the parsed JSON response data

                    //if the server was able to create the new file successfully
                    if (message.status === "success") {
                        fileDropDown.append(`<option value="${message.name}">${message.name}</option>`);  //append the newly created file to the drop down list
                        fileDropDown.val(message.name);     //make the currently selected file the one that was just created
                        openedFile = message.name;          //set the openedFile global equal to the file that was just created by the server

                        //alert that the new file was created and saved successfully
                        alert("The text edit space contents have been successfully saved to the file " + message.name + "!");
                    }
                    //alert the user of an error if the server was unable to create and save the file succesfully because of invalid name format
                    else if (message.status === "failure") {
                        alert("Error: Invalid file name format.");
                    }
                    //alert the user of an error if the server was unable to create and save the file successfully because the extension was invalid
                    else if (message.status === "failure-invalid extension") {
                        alert("Error: Invalid file extension. It must be an extension for a file that would contain human readable content.");
                    }
                    //alert the user of an error if the server was unable to create and save the file successfully because a file with the same name 
                    //already exists
                    else if (message.status === "file exists") {
                        alert("Error: The file " + message.name + " already exists.");
                    }
                },
                //the following code occurs only if the response is not received successfully
                error: function () {
                    alert("Error. Response not received.");
                }
            });

            //clear out the new file name input field
            $("#fileNameInput").val("");
        });

    </script>
    <title>My Text Editor</title>
</head>
<body>
    <form id="textEditor" name="textEditor" runat="server">
        <table border="0">
            <tr>
                <td style="text-align: right; width: 300px;">
                    <input type="button" id="openFileBtn" value="Open File"/>
                </td>
                <td style="text-align: left; width: 300px;">
                   <select id="filesList">
                   </select>
                </td>
            </tr>
        </table>
        <textarea id="textEditSpace" style="width: 600px; height: 600px; padding: 10px; text-align: left; vertical-align: top;"></textarea>
        <table border="0">
    <tr>
        <td style="vertical-align: central; text-align: center; width: 300px; height: 75px">
            <input type="button" id="saveBtn" value="Save"/>
        </td>
        <td style="vertical-align: central; text-align: center; width: 300px; height: 75px">
            <input type="button" id="saveAsBtn" value="Save As"/>
            <input type="text" id="fileNameInput"/>
        </td>
    </tr>
</table>
    </form>
</body>
</html>
