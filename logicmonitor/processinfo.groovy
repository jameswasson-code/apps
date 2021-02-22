import com.santaba.agent.groovyapi.win32.WMI

// Set hostname variable.
def hostname = hostProps.get("system.hostname");

// Try the following code.
try
{
    // This is our namespace, we're using the default value here to illustrate
    // how to pass it if your object isn't in root\cimv2
    // This parameter is optional.
    def namespace = "CIMv2";

    // You can also pass an optional timeout value, the default is 30 seconds
    def timeout = 30;

    // This is our WMI query.
    def wmi_query = 'select NAME from Win32_PerfRawData_PerfProc_Process';

    // instantiate the WMI class object
    def wmi_output = WMI.queryAll(hostname, namespace, wmi_query, timeout);

	// Write a list of unique processes, after stripping /#\d+/ from the ends of names if it's there.
	// Not keeping the list, just using it to keep track of what we already know.
	processList = [];
	wmi_output.each
	{ process ->
		processName = process['NAME'];
		baseProcessName = processName.split('#')[0]
		wildvalue = baseProcessName.replaceAll('[ :#=.\\\\]','_');
		if(!processList.contains(wildvalue))
		{
			// First time we've found this process name wildvalue, add it to the list and print it out
			processList << baseProcessName
			println wildvalue + '##' + baseProcessName;
		}
	}
    // Exit by returning 0.
    return 0;
}

// Catch any exceptions that may have occurred.
catch (Exception e)
{
    // Print exception out.
    println e
    return 1;
}
