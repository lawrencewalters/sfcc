import xml.etree.ElementTree as ET

def extract_jobs_with_execute_script_module(xml_file):
    tree = ET.parse(xml_file)
    root = tree.getroot()
    namespace = {'ns': 'http://www.demandware.com/xml/impex/jobs/2015-07-01'}

    jobs = []
    unique_modules = set()

    for job in root.findall('ns:job', namespace):
        job_id = job.get('job-id')
        enabled = False
        for trigger in job.findall('.//ns:triggers/ns:run-recurring', namespace):
            if trigger.get('enabled') == 'true':
                enabled = True
                break
         
        for param in job.findall('.//ns:parameter[@name="Action"]', namespace):
            param_value = param.text
            jobs.append({'job-id': job_id, 'ModuleOrAction': param_value,'enabled': enabled})
            unique_modules.add(param_value)
        for step in job.findall('.//ns:step[@type="ExecuteScriptModule"]', namespace):
            module = step.find('ns:parameters/ns:parameter[@name="ExecuteScriptModule.Module"]', namespace)
            if module is not None:
                module_value = module.text
                jobs.append({'job-id': job_id, 'ModuleOrAction': module_value,'enabled': enabled})
                unique_modules.add(module_value)

    return jobs, unique_modules

def main():
    xml_file = 'jobs.xml'
    jobs, unique_modules = extract_jobs_with_execute_script_module(xml_file)
    for job in jobs:
        print(f"{job['job-id']},{job['ModuleOrAction']},{job['enabled']}")
    
    print("\nUnique ExecuteScriptModule.Module values:")
    for module in unique_modules:
        print(module)
    

if __name__ == "__main__":
    main()