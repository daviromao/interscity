# Requests

Requests to this service usually involve receiving or sending a data structure
in JSON format. Check out the example below:


```json
{
  "resources": [
    {
      "uuid": "ae9cf502-5ed2-47d4-914c-c1caec1c41c4",
      "capabilities": {
        "environment_monitoring": [
          {
            "temperature": "38.313",
            "humidity": "38.313",
            "date": "2016-06-21T23:27:35.000Z"
          },
          {
            "temperature": "28.237",
            "humidity": "28.237",
            "date": "2016-06-20T06:37:52.000Z"
          }
        ],
      }
    },
    {
      "uuid": "56tcf598-3tg1-77d9-034t-w5ajis5u44c7",
      "capabilities": {
        "medical_procedure": [
          {
            "patient": {
              "name": "Thomas S. Seibel",
              "age": "18",
            },
            "speciality": "surgery",
            "date": "2016-03-01 09:01:00"
          },
          {
            "patient": {
              "name": "Jose R. Garcia",
              "age": "17",
            },
            "speciality": "psychiatry",
            "date": "2016-03-01 10:01:00"
          },
          {
            "patient": {
              "name": "Débora M. Wright",
              "age": "26",
            },
            "speciality": "psychiatry",
            "date": "2016-03-02 08:01:00"
          },
          {
            "patient": {
              "name": "Jose J. Whetsel",
              "age": "55",
            },
            "speciality": "surgery",
            "date": "2016-03-03 07:01:00"
          }
        ]
      }
    }
  ]
}
```


The fields presented on the above example may vary according to the request.


 Data Collector API 
====================

All interactions with the Data Collector are done through HTTP REST requests. Field description:  
  
* **uuid**: A non-quoted String corresponding to the resource's uuid 
(not to be confused with the local id assigned by the Data Collector!).
* **capabilities**: Capabilities represents the kind of data a resource is
able to provide.
* **specific_value**:  A given capability may have several related attributes
collected by time. For example, the **environment_monitoring** capability
could collect data regarding the following attributes: *temperature, humidity,
and pressure*. Thus, a collect value will have an additional key
for each of these attributes with their respective values.
* **date**: This field respresent the date-time when the data was collected.

###  Getting data from all resources

`POST /resources/data`

**Description**:

Returns all the data history from all resources. Every data has an array of
Details; each Detail contains the value collected, the capability (such as
"environment\_monitoring", "luminosity", ...) and date.

**Usage example**:

```shell
curl -X POST http://localhost:3000/resources/data`
```

Returns a JSON data structure similar to the following:

```json
 {
  "resources": [
    {
      "uuid": "ae9cf502-5ed2-47d4-914c-c1caec1c41c4",
      "capabilities": {
        "environment_monitoring": [
          {
            "temperature": "38.313",
            "humidity": "38.313",
            "date": "2016-06-21T23:27:35.000Z"
          },
          {
            "temperature": "28.237",
            "humidity": "28.237",
            "date": "2016-06-20T06:37:52.000Z"
          }
        ],
      }
    },
    {
      "uuid": "56tcf598-3tg1-77d9-034t-w5ajis5u44c7",
      "capabilities": {
        "medical_procedure": [
          {
            "patient": {
              "name": "Thomas S. Seibel",
              "age": "18",
            },
            "speciality": "surgery",
            "date": "2016-03-01 09:01:00"
          },
          {
            "patient": {
              "name": "Jose R. Garcia",
              "age": "17",
            },
            "speciality": "psychiatry",
            "date": "2016-03-01 10:01:00"
          },
          {
            "patient": {
              "name": "Débora M. Wright",
              "age": "26",
            },
            "speciality": "psychiatry",
            "date": "2016-03-02 08:01:00"
          },
          {
            "patient": {
              "name": "Jose J. Whetsel",
              "age": "55",
            },
            "speciality": "surgery",
            "date": "2016-03-03 07:01:00"
          }
        ]
      }
    }
  ]
}
```

**HTTP status codes returned**:

*    **200 (OK)**: Request successful.
*    **500 (Internal Server Error)**: A problem in the Data Collector server occurred.


### Getting data from a specific resource or set of resources

`POST /resources/:uuid/data`

**Description**:

Returns all data history of an specified resources.

**Usage example for a specific resource**:

```shell
curl -X POST http://localhost:3000/resources/102503b2-59ee-445c-a20b-99fd10b01c19/data
```

**Usage example for a set of resources**:

```shell
curl -H "Content-Type: application/json" -X POST -d '{"uuids":["5ad20589-a3db-4521-b1bc-a21dde00a25c","b5d170b5-aaf3-42bc-9e47-58e3fe2a4846"]}' http://localhost:3000/resources/data
```

Returns a JSON data structure similar to the following:

```json
{
"resources": [
    {
      "uuid": "ae9cf502-5ed2-47d4-914c-c1caec1c41c4",
      "capabilities": {
       "environment_monitoring": [
          {
            "temperature": "38.313",
            "humidity": "38.313",
            "date": "2016-06-21T23:27:35.000Z"
          },
          {
            "temperature": "28.237",
            "humidity": "28.237",
            "date": "2016-06-20T06:37:52.000Z"
          }
        ],
      }
    }
  ]
}
```

**HTTP status codes returned**:

*    **200 (OK)**: Request successful.
*    **400 (Bad Request)**: Returned when the specified :uuid was not found.
*    **500 (Internal Server Error)**: A problem in the Data Collector server occurred.

### Getting last data from a specific resource or set of resources 

`POST /resources/:uuid/data/last`

**Description**:

Returns the last Data collected from the capability of a specific resource.

**Usage example for a specific resource**:

```shell
curl -X POST http://localhost:3000/resources/102503b2-59ee-445c-a20b-99fd10b01c19/data/last
```

**Usage example for a set of resources**:

```shell
curl -H "Content-Type: application/json" -X POST -d '{"uuids":["5ad20589-a3db-4521-b1bc-a21dde00a25c","b5d170b5-aaf3-42bc-9e47-58e3fe2a4846"]}}' http://localhost:3000/resources/data/last
```

Returns a JSON data structure similar to the following:

```json
{
"resources": [
    {
      "uuid": "ae9cf502-5ed2-47d4-914c-c1caec1c41c4",
      "capabilities": {
       "environment_monitoring": [
          {
            "temperature": "28.237",
            "humidity": "28.237",
            "date": "2016-06-20T06:37:52.000Z"
          }
        ],
      }
    }
  ]
}
```

**HTTP status codes returned:**

*   **200 (OK):** Request successful.
*    **400 (Bad Request):** Returned when the specified :uuid was not found.
*    **500 (Internal Server Error):** A problem in the Data Collector server occurred.

### Getting the last data from all resources

`POST /resources/data/last`

**Description:**

Returns the last Data collected from the capability of a all resources. 

**Usage example:**

```shell
curl -X POST http://localhost:3000/resources/data/last
```

Returns a JSON data structure similar to the following:

```json
{
  "resources": [
    {
      "uuid": "ae9cf502-5ed2-47d4-914c-c1caec1c41c4",
      "capabilities": {
        "environment_monitoring": [
          {
            "temperature": "38.313",
            "humidity": "38.313",
            "date": "2016-06-21T23:27:35.000Z"
          },
          {
            "temperature": "28.237",
            "humidity": "28.237",
            "date": "2016-06-20T06:37:52.000Z"
          }
        ],
      }
    },
    {
      "uuid": "56tcf598-3tg1-77d9-034t-w5ajis5u44c7",
      "capabilities": {
        "medical_procedure": [
          {
            "patient": {
              "name": "Jose J. Whetsel",
              "age": "55",
            },
            "speciality": "surgery",
            "date": "2016-03-03 07:01:00"
          }
        ]
      }
    }
  ]
}
```

**HTTP status codes returned:**

   * **200 (OK):** Request successful.
   * **500 (Internal Server Error):** A problem in the Data Collector server occurred.


Filters
============================

**Field Description**

* **capabilities:**  An array with one or more capability names. If
a sensor value is related to at least one of the informed capabilities,
it will be included on the results.
* **start_date/end_date:** Represent the date-time range in ISO- 8601 format.
You may use one of them or combine both.
* **matchers:** A set of match operators to filter the values of
capability's attributes. The following matchers are available:
  * **eq** - Specifies equality condition
  * **gt** - Selects those data where the value of the specified attribute
  is greater than a specified value
  * **gte** - Selects those data where the value of the specified attribute
  is greater than or equal a specified value
  * **lt** - Selects those data where the value of the specified attribute
  is less than a specified value
  * **lte** - Selects those data where the value of the specified attribute
  is less than or equal a specified value
  * **in** - Selects those data where the value of the specified attribute
  equals any value in the specified array
  * **ne** - Selects those data where the value of the specified attribute
  is not equal to a specified value. It's is a good idea to use this
  filter combined with the **capabilities** to avoid returning data that do
  not even have this attribute


### By capability

**Description:**

Filter the data collected by capability or a capability range.

**Usage example for a capability**

```shell
curl -H "Content-Type: application/json" -X POST -d '{"capabilities":["tofu"]}' http://localhost:3000/resources/data
```
Usage example for several capabilities

```shell
curl -H "Content-Type: application/json" -X POST -d '{"capabilities":["tofu","loko","flannel","meditation"]}' http://localhost:3000/resources/data
```

### By date

Filter the data collected by date. This filter can be applied using a date or a range date.

Usage example for date

```shell
curl -H "Content-Type: application/json" -X POST -d '{"start_date":"2016-06-25T12:21:29"}' http://localhost:3000/resources/data
```

Usage  example for range date

```shell
curl -H "Content-Type: application/json" -X POST -d '{"start_date":"2016-06-25T12:21:29","end_date":"2016-06-25T16:21:29"}' http://localhost:3000/resources/data
```

### By Matchers

Filter the data collected through value matchers. This filter must be used 
on the specific attribute of collected values.
The examples used bellow, considers the following capabilities and attributes:

* capability: environment\_monitoring
  * attributes:
    * temperature
    * humidity
    * pressure
* capability: medical\_procedure
  * attributes:
    * patient
    * speciality

Usage example for a single attribute:

```shell
curl -H "Content-Type: application/json" -X POST -d '{"matchers":{"temperature.eq":"13.498"}}' http://localhost:3000/resources/data
```

Usage example for the *gte* and *lte* operators:

```shell
curl -H "Content-Type: application/json" -X POST -d '{"matchers":{"temperature.gte":"13.498", "temperature.lte":"18.091"}}' http://localhost:3000/resources/data
```

Usage example for the *in* operator. It also uses a more complex attribute:

```shell
curl -H "Content-Type: application/json" -X POST -d '{"matchers":{"patient.age.in":["10", "20", "30"]}}' http://localhost:3000/resources/data
```

**HTTP status codes returned:**

*  **200 (OK):** Request successful.
*  **400 (Bad Request):** Returned when the specified parameter was not found.
*  **500 (Internal Server Error):** A problem in the Data Collector server occurred.

