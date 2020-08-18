# Fibaro devices HTTP exporter

Gives ability to export device information to external url.

It sends minimal set of information about devices added to Fibaro Home Center unit.

Skips all hidden, disabled, dead and non "com.fibaro." devices.

It should help building widgets on your websites or integrate products.

Document structure

```
{
    id: integer
    name: string
    type: string
    basetype: string
    properties: {
        userDescription: string
        quickAppVariables: array
        value: mixed
        manufacturer: string
        model: string
        categories: string[]
        zwaveInfo: string
        dead: boolean
        unit: string
    }
}
```
