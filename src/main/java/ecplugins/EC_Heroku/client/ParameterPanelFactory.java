package ecplugins.EC_Heroku.client;

import com.google.gwt.core.client.JavaScriptObject;

import com.electriccloud.commander.gwt.client.Component;
import com.electriccloud.commander.gwt.client.ComponentBaseFactory;
import com.electriccloud.commander.gwt.client.ComponentContext;
import org.jetbrains.annotations.NotNull;

public class ParameterPanelFactory extends ComponentBaseFactory
{
    @NotNull
    @Override
    public Component createComponent(ComponentContext jso)
    {
        String className = ParameterPanelFactory.getComponentName();
        Component oComponent = null;
        if(className.equals("AddOnsManagementParameterPanel")){
            oComponent = new AddOnsManagementParameterPanel();
        }else if(className.equals("ApplicationManagementParameterPanel")){
            oComponent = new ApplicationManagementParameterPanel();
        }else if(className.equals("CollaboratorManagementParameterPanel")){
            oComponent = new CollaboratorManagementParameterPanel();
        }else if(className.equals("ConfigurationManagementParameterPanel")){
            oComponent = new ConfigurationManagementParameterPanel();
        }else if(className.equals("DeployApplicationParameterPanel")){
            oComponent = new DeployApplicationParameterPanel(); 
        }else if(className.equals("ProcessManagementParameterPanel")){
            oComponent = new ProcessManagementParameterPanel();
        }else if(className.equals("ReleasesManagementParameterPanel")){
            oComponent = new ReleasesManagementParameterPanel();
        }else{//SSHKeysManagement
            oComponent = new SSHKeysManagementParameterPanel();
        }
        return oComponent;
    }
}
