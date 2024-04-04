// Define the custom picklist widget
var dynamicPicklistWidget = {
    name: "dynamicpicklist",
    title: "Dynamic Picklist",
    iconName: "icon-dynamicpicklist",
    
    // Custom widget initialization
    widgetIsLoaded: function() {
      // Load external libraries or resources if needed
    },
    
    // Render the widget
    willMount: function(question, el) {
      // Create a select element
      var select = document.createElement("select");
      
      // Add any necessary attributes to the select element
      select.name = question.name;
      select.id = question.inputId;
      
      // Fetch the picklist values from the external endpoint
      const url = '';
      fetch(url)
        .then(function(response) {
          return response.json();
        })
        .then(function(data) {
          // Populate the select element with the dynamic picklist values
          data.forEach(function(item) {
            var option = document.createElement("option");
            option.value = item.value;
            option.text = item.text;
            select.appendChild(option);
          });
          
          // Set the default value or previously selected value if available
          select.value = question.value || "";
          
          // Update the survey response when the user selects an option
          select.addEventListener("change", function() {
            question.value = select.value;
          });
        })
        .catch(function(error) {
          console.error("Failed to fetch picklist values:", error);
        });
      
      // Add the select element to the survey question container
      el.appendChild(select);
    },
    
    // Update the widget's display based on the survey response
    willUnmount: function(question, el) {
      // Clean up any event listeners or resources
    }
  };
  
  // Register the custom widget with SurveyJS
  Survey.CustomWidgetCollection.Instance.addCustomWidget(dynamicPicklistWidget);
  

// var widget = {
//     //the widget name. It should be unique and written in lowcase.
//     name: "textwithbutton",
//     //the widget title. It is how it will appear on the toolbox of the SurveyJS Editor/Builder
//     title: "Text with button",
//     //the name of the icon on the toolbox. We will leave it empty to use the standard one
//     iconName: "",
//     //If the widgets depends on third-party library(s) then here you may check if this library(s) is loaded
//     widgetIsLoaded: function () {
//         //return typeof $ == "function" && !!$.fn.select2; //return true if jQuery and select2 widget are loaded on the page
//         return true; //we do not require anything so we just return true. 
//     },
//     //SurveyJS library calls this function for every question to check, if it should use this widget instead of default rendering/behavior
//     isFit: function (question) {
//         //we return true if the type of question is textwithbutton
//         return question.getType() === 'textwithbutton';
//         //the following code will activate the widget for a text question with inputType equals to date
//         //return question.getType() === 'text' && question.inputType === "date";
//     },
//     //Use this function to create a new class or add new properties or remove unneeded properties from your widget
//     //activatedBy tells how your widget has been activated by: property, type or customType
//     //property - it means that it will activated if a property of the existing question type is set to particular value, for example inputType = "date" 
//     //type - you are changing the behaviour of entire question type. For example render radiogroup question differently, have a fancy radio buttons
//     //customType - you are creating a new type, like in our example "textwithbutton"
//     activatedByChanged: function (activatedBy) {
//         //we do not need to check acticatedBy parameter, since we will use our widget for customType only
//         //We are creating a new class and derived it from text question type. It means that text model (properties and fuctions) will be available to us
//         Survey.JsonObject.metaData.addClass("textwithbutton", [], null, "text");
//         //signaturepad is derived from "empty" class - basic question class
//         //Survey.JsonObject.metaData.addClass("signaturepad", [], null, "empty");
  
//         //Add new property(s)
//         //For more information go to https://surveyjs.io/Examples/Builder/?id=addproperties#content-docs
//         Survey.JsonObject.metaData.addProperties("textwithbutton", [
//             { name: "buttonText", default: "Click Me" }
//         ]);
//     },
//     //If you want to use the default question rendering then set this property to true. We do not need any default rendering, we will use our our htmlTemplate
//     isDefaultRender: false,
//     //You should use it if your set the isDefaultRender to false
//     htmlTemplate: "<div><input /><button></button></div>",
//     //The main function, rendering and two-way binding
//     afterRender: function (question, el) {
//         //el is our root element in htmlTemplate, is "div" in our case
//         //get the text element
//         var text = el.getElementsByTagName("input")[0];
//         //set some properties
//         text.inputType = question.inputType;
//         text.placeholder = question.placeHolder;
//         //get button and set some rpoeprties
//         var button = el.getElementsByTagName("button")[0];
//         button.innerText = question.buttonText;
//         button.onclick = function () {
//             question.value = "You have clicked me";
//         }
  
//         //set the changed value into question value
//         text.onchange = function () {
//             question.value = text.value;
//         }
//         onValueChangedCallback = function () {
//             text.value = question.value ? question.value : "";
//         }
//         onReadOnlyChangedCallback = function() {
//           if (question.isReadOnly) {
//             text.setAttribute('disabled', 'disabled');
//             button.setAttribute('disabled', 'disabled');
//           } else {
//             text.removeAttribute("disabled");
//             button.removeAttribute("disabled");
//           }
//         };
//         //if question becomes readonly/enabled add/remove disabled attribute
//         question.readOnlyChangedCallback = onReadOnlyChangedCallback;
//         //if the question value changed in the code, for example you have changed it in JavaScript
//         question.valueChangedCallback = onValueChangedCallback;
//         //set initial value
//         onValueChangedCallback();
//         //set initial readOnly if needed
//         onReadOnlyChangedCallback();
//     },
//     //Use it to destroy the widget. It is typically needed by jQuery widgets
//     willUnmount: function (question, el) {
//         //We do not need to clear anything in our simple example
//         //Here is the example to destroy the image picker
//         //var $el = $(el).find("select");
//         //$el.data('picker').destroy();
//     }
//   }
  
//   //Register our widget in singleton custom widget collection
//   Survey.CustomWidgetCollection.Instance.addCustomWidget(widget, "customtype");

//   const iconId = "icon-datepicker";
//   const componentName = "datepicker";
  
  
// var widget_date_picker = {
//     name: componentName,
//     title: 'Date picker',
//     iconName: iconId,
//     widgetIsLoaded: function () {
//         return !!$ && !!$.fn.datepicker && !$.fn.datepicker.noConflict;
//     },
//     isFit: function (question) {
//         return question.getType() === componentName;
//     },
//     htmlTemplate: "<input class='form-control widget-datepicker' type='text'>",
//     activatedByChanged: function (activatedBy) {
//         Survey.Serializer.addClass(
//             componentName,
//             [
//                 { name: 'inputType', visible: false },
//                 { name: 'inputFormat', visible: false },
//                 { name: 'inputMask', visible: false },
//             ],
//             null,
//             'text'
//         );
//         let registerQuestion =
//             Survey.ElementFactory.Instance.registerCustomQuestion;
//         if (!!registerQuestion) registerQuestion(componentName);
//         Survey.Serializer.addProperty(componentName, {
//             name: 'dateFormat',
//             category: 'general',
//         });
//         Survey.Serializer.addProperty(componentName, {
//             name: 'config',
//             category: 'general',
//             visible: false,
//             default: null,
//         });
//         Survey.Serializer.addProperty(componentName, {
//             name: 'maxDate',
//             category: 'general',
//         });
//         Survey.Serializer.addProperty(componentName, {
//             name: 'minDate',
//             category: 'general',
//         });
//         Survey.Serializer.addProperty(componentName, {
//             name: 'disableInput:boolean',
//             category: 'general',
//         });
//     },
//     afterRender: function (question, el) {
//         var $el = $(el).is('.widget-datepicker')
//             ? $(el)
//             : $(el).find('.widget-datepicker');
//         $el.addClass(question.css.text.root);
//         var isSelecting = false;
//         var config = $.extend(true, {}, question.config || {});
//         if (!!question.placeHolder) {
//             $el.attr('placeholder', question.placeHolder);
//         }
//         if (config.dateFormat === undefined) {
//             config.dateFormat = !!question.dateFormat
//                 ? question.dateFormat
//                 : undefined;
//         }
//         if (config.option === undefined) {
//             config.option = {
//                 minDate: null,
//                 maxDate: null,
//             };
//         }
//         if (!!question.minDate) {
//             config.minDate = question.minDate;
//         }
//         if (!!question.maxDate) {
//             config.maxDate = question.maxDate;
//         }
//         if (!!question.renderedMin) {
//             config.minDate = new Date(question.renderedMin);
//         }
//         if (!!question.renderedMax) {
//             config.maxDate = new Date(question.renderedMax);
//         }
//         config.disabled = question.isReadOnly;
//         if (config.onSelect === undefined) {
//             config.onSelect = function (dateText) {
//                 isSelecting = true;
//                 setDateIntoQuestion();
//                 isSelecting = false;
//                 this.fixFocusIE = true;
//             };
//         }
//         config.fixFocusIE = false;
//         config.onClose = function (dateText, inst) {
//             this.fixFocusIE = true;
//         };
//         config.beforeShow = function (input, inst) {
//             var result = !!navigator.userAgent.match(/Trident\/7\./)
//                 ? !this.fixFocusIE
//                 : true;
//             this.fixFocusIE = false;
//             return result;
//         };
//         function setDateIntoQuestion() {
//             var val = $el.datepicker('getDate');
//             var d = new Date();
//             val.setHours(d.getHours());
//             val.setMinutes(d.getMinutes());
//             val.setSeconds(d.getSeconds());
//             question.value = val;
//         }
//         var pickerWidget = $el.datepicker(config).on('change', function (e) {
//             setDateIntoQuestion();
//         });

//         $el.keyup(function (e) {
//             if (e.keyCode == 8 || e.keyCode == 46) {
//                 $.datepicker._clearDate(this);
//             }
//         });
//         if (question.disableInput) {
//             $el.attr('readOnly', 'true');
//         }

//         question.readOnlyChangedCallback = function () {
//             $el.datepicker('option', 'disabled', question.isReadOnly);
//         };
//         function updateDate() {
//             if (!question.isEmpty()) {
//                 var val = question.value;
//                 if (typeof val === 'string') {
//                     val = new Date(val);
//                 }
//                 pickerWidget.datepicker('setDate', val);
//             } else {
//                 pickerWidget.datepicker('setDate', null);
//             }
//         }
//         question.registerFunctionOnPropertyValueChanged(
//             'dateFormat',
//             function () {
//                 question.dateFormat &&
//                     pickerWidget.datepicker(
//                         'option',
//                         'dateFormat',
//                         question.dateFormat
//                     );
//                 updateDate();
//             }
//         );
//         question.valueChangedCallback = function () {
//             if (!isSelecting) {
//                 updateDate();
//                 $el.blur();
//             }
//         };
//         question.valueChangedCallback();
//     },
//     willUnmount: function (question, el) {
//         var $el = $(el).is('.widget-datepicker')
//             ? $(el)
//             : $(el).find('.widget-datepicker');
//         $el.datepicker('destroy');
//     },
//     pdfQuestionType: 'text',
// };

// Survey.CustomWidgetCollection.Instance.addCustomWidget(widget_date_picker, 'customtype');

// var searchStringWidget = {
//     //the widget name. It should be unique and written in lowercase.
//     name: "searchstring",
//     //SurveyJS library calls this function for every question to check 
//     //if this widget should apply to the particular question.
//     isFit: function (question) {
//         //We are going to apply this widget for comment questions (textarea)
//         return question.getType() == "comment";
//     },
//     //We will change the default rendering, but do not override it completely
//     isDefaultRender: true,
//     //"question" parameter is the question we are working with and "el" parameter is HTML textarea in our case
//     afterRender: function (question, el) {
//         //Create a div with an input text and a button inside
//         var mainDiv = document.createElement("div");
//         var searchEl = document.createElement("input");
//         searchEl.style.width = "calc(100% - 120px)";
//         var btnEl = document.createElement("button");
//         btnEl.innerText = "Search";
//         btnEl.style.width = "120px";
//         var searchIndex = 0;
//         //Start searching from the beginning on changing the search text
//         searchEl.onchange = function () {
//             searchIndex = 0;
//         };
//         //Do the search on button click
//         btnEl.onclick = function () {
//             var searchText = searchEl.value;
//             var text = el.value;
//             //Do nothing if search text or textarea is empty
//             if (!searchText || !text) return;
//             var index = text.indexOf(searchText, searchIndex + 1);
//             //If nothing found, but started not from the beginning then start from the beginning
//             if (index < 0 && searchIndex > -1) {
//                 index = text.indexOf(searchText, 0);
//             }
//             searchIndex = index;
//             //If found the text then focus the textarea and select the search text.
//             if (index > -1) {
//                 el.focus();
//                 el.setSelectionRange(index, index + searchText.length);
//             }
//         };
//         mainDiv.appendChild(searchEl);
//         mainDiv.appendChild(btnEl);
//         //Append the div with search input and button before textarea
//         el.parentElement.insertBefore(mainDiv, el);
//     },
// };

// //Register our widget in singleton custom widget collection
// Survey.CustomWidgetCollection.Instance.add(searchStringWidget);


// Survey.CustomWidgetCollection.Instance.addCustomWidget(widget, 'customtype');
