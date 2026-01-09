# InterSystems Business Intelligence and Reporting

As a complete data-platform, InterSystems IRIS has solutions for every step in the process of transforming data to insight. Data can be loaded from various sources, transformed with tools like [dbt-iris](https://pypi.org/project/dbt-iris/) and used to generate predictions with [integratedML](../ML/integratedML.md). Visualising and reporting on data is equally flexible, with options for every use case.

There are three options for reporting on data stored in InterSystems IRIS. Following an overview of the available options, there is a guide to using IRIS BI, the built-in tool included with InterSystems IRIS installation.

For an overview of all the analytics tools and offerings available see [A Whirlwind Tour of the Analytics Buffet | Youtube](https://www.youtube.com/watch?v=A4qAbMMQMaA)

## IRIS BI (formerly DeepSee)

Built-in tool for creating cubes, pivot tables and dashboards. IRIS BI is shipped with InterSystems IRIS and works close to the data.

### Installation and License

- Shipped with InterSystems IRIS
- Standard InterSystems IRIS License

### Best For

- Operating on real time data.
- Uses where analytics features are required within the application.

### More Information on IRIS BI

- [IRIS-BI Quickstart | Developer Hub](./IRIS-BI.md)
- [InterSystems IRIS Business Intelligence - Tips & Tricks](https://www.youtube.com/watch?v=Ekjzny8zj98)
- [Introduction to Business Intelligence | Documentation](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=D2GS_ch_intro)
- [Getting Started Tutorial | Documentation](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=D2DT_ch_setup)
- [BI Sample data, Cubes and Dashboards | GitHub](https://github.com/intersystems/Samples-BI)
- [Analyzing Data with InterSystems IRIS BI | Learning Services](https://learning.intersystems.com/course/view.php?id=1793)

## InterSystems Reports

InterSystems Reports enables designing and sharing responsive web reports or pixel-perfect page reports for printing. It supports role-based security, automatic scheduling and distribution and advanced visualisation. Reports can be exported into multiple formats (including PDF, Excel, HTML and Word) and embedded into applications.

InterSystems Reports has two parts, a designer IDE and a server for hosting web reports, scheduling future reports and automating the report distribution.

### Installation and Licence

- Requires separate installation of Report Editor and Report Server
- Available with Advanced Server License

### Best For

- Creating pixel-perfect printable reports (e.g. invoices, regulatory documents)
- Report scheduling and distribution  
- Interactive web-based reporting for end-users

For more information about InterSystems Reports see [Moving To InterSystems Reports | Youtube](https://www.youtube.com/watch?v=ioHHCzEtGoQ).

### More information on InterSystems Reports

- [Introduction to InterSystems Reports | Documentation](https://docs.intersystems.com/components/csp/docbook/DocBook.UI.Page.cls?KEY=GISR_intro)
- [Delivering Data Visually with InterSystems Reports | Learning Services](https://learning.intersystems.com/course/view.php?id=1490)

## Adaptive Analytics

Adaptive Analytics is an extension that adds a business-oriented semantic layer between InterSystems IRIS and popular BI tools like PowerBI, Tableau, and Excel. It provides a centralized virtual data model for consistent metrics, supports self-service BI, and accelerates queries with machine-learning-driven aggregations. Data remains in IRIS for optimal performance, and security is enforced through governed access. This solution is ideal for organizations needing consistent definitions across BI tools, fast OLAP analysis, and scalable performance without data duplication.

### Installation and License

- Requires Installation of AtScale.
- Licensed per core, speak to Sales for detailed guidance.

### Best For

- Enterprises needing consistent metrics across multiple BI tools
- Organizations that want governed, secure access to sensitive data
- Self-service analytics for business users without IT dependency

### More information on Adaptive Analytics

- [Adaptive Analytics | Data Sheet](https://www.intersystems.com/resources/accelerate-time-to-insight-with-intersystems-iris-adaptive-analytics/)
- [Build Data Models Using Adaptive Analytics | Learning Services](https://learning.intersystems.com/course/view.php?id=1791)
- [InterSystems IRIS Adaptive Analytics | Documentation](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=AADAN)

## Direct Connection from Third-party BI Tools

Alongside the native support through the above platforms, InterSystems IRIS is open to use with standard tools and connections.

Tools like Microsoft PowerBI, Microsoft Excel and Tableau can access data stored on InterSystems IRIS through JDBC or ODBC connections.

PowerBI also includes an InterSystems IRIS connector, which can allow access to IRIS BI Cubes and Pivot tables.

### Installation and License

- May require driver or connector installation (e.g. ODBC driver installation)
- Standard InterSystems IRIS License

### Best For

- Simple connection of third-party applications to IRIS

### More Information On connecting Third-party BI Tools

- [Getting Started: ODBC Connections to InterSystems Databases | Documentation](https://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=BNETODBC_intro)
- [JDBC for Relational Access | Documentation](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=PAGE_java_jdbc)
- [Connect Data Stored in an InterSystems Product to Power BI | Documentation](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=APOWER)

## Comparison

| Feature / Criteria        | **IRIS BI** (Built-in)                  | **InterSystems Reports**                     | **Adaptive Analytics**                       | **Direct BI Connection**                  |
|---------------------------|-----------------------------------------|---------------------------------------------|---------------------------------------------|-------------------------------------------|
| **Purpose**              | Embedded analytics, cubes, dashboards | Pixel-perfect layouts, interactive web reports, scheduling & distribution            | Access layer for third-party BI tools      | Simple connection to BI tools            |
| **Best For**             | Real-time data, in-app analytics       | Regulatory/compliance reports, scheduled distribution | Consistent results across all third-party applications     | Quick integration with PowerBI, Tableau  |
| **Installation**         | Included with IRIS                     | Separate install (Editor + Server)         | Separata install              | ODBC driver or PowerBI Connector                   |
| **License**              | Standard IRIS license                  | Advanced Server license                    | Licensed per core                          | Standard IRIS license                    |
| **Integration**          | Native to IRIS                         | Web reports          | Tableau, PowerBI, Excel                    | PowerBI connector, JDBC/ODBC             |
