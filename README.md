ADROVMapper
===========

iOS - Map objects to corresponding views / view controllers and back. This won't take care of all cases (for example, custom pickers), but in my experience handles most object/view bindings quite well.

Step 1: Make sure your views' properties match your objects' properties
Example: If you have an Employee object with properties firstName, lastName, and hireDate, your corresponding view's properties (whether they are labels, text fields, etc) should be named EXACTLY the same

Step 2: Initialize an ADROVMapper object and with your view and data object
Example: ADROVMapper *mapper = [ADROVMapper mapperWithView:myView object:myObject];

Step 3: Call the updateView or updateObject methods to perform mapping from one to the other
Example: [mapper updateView];

DATE FORMAT: The default date format for going from an NSDate property to a text UI property (label, text field, etc) is "MM/dd/yyyy". You can specify a different date format when creating the mapper object or set the date format later.

CURRENCY TAGS: ADROVMapper uses special strings to determine if a property should be formatted as currency for display in a text UI property (label, text field, etc). The default currency tags are "amount", "balance", "price" and "msrp". These tags should be contained in the name of the property (for example, "unitPrice" or "totalChargeAmount"). You can change the defaults in the ADROVMapper.m file or specify your own currency tags when creating the mapper object, or set them later.
