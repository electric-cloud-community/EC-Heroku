
// ConfigurationManagementParameterPanel.java --
//
// ConfigurationManagementParameterPanel.java is part of ElectricCommander.
//
// Copyright (c) 2005-2012 Electric Cloud, Inc.
// All rights reserved.
//

package ecplugins.EC_Heroku.client;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.logical.shared.ValueChangeEvent;
import com.google.gwt.event.logical.shared.ValueChangeHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiFactory;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.TextArea;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.Widget;

import com.electriccloud.commander.client.domain.ActualParameter;
import com.electriccloud.commander.client.domain.FormalParameter;
import com.electriccloud.commander.client.util.StringUtil;
import com.electriccloud.commander.gwt.client.ComponentBase;
import com.electriccloud.commander.gwt.client.ui.FormBuilder;
import com.electriccloud.commander.gwt.client.ui.ParameterPanel;
import com.electriccloud.commander.gwt.client.ui.ParameterPanelProvider;
import com.electriccloud.commander.gwt.client.ui.ValuedListBox;

/**
 * Basic component that is meant to be cloned and then customized to perform a
 * real function.
 */
public class ConfigurationManagementParameterPanel
    extends ComponentBase
    implements ParameterPanel,
        ParameterPanelProvider
{

    //~ Static fields/initializers ---------------------------------------------

    // ~ Static fields/initializers----------------------------
    private static UiBinder<Widget, ConfigurationManagementParameterPanel> s_binder =
        GWT.create(Binder.class);

    // These are all the formalParameters on the Procedure
    static final String CONFIGNAME = "ConfigName";
    static final String ACTION     = "Action";
    static final String APPNAME    = "AppName";
    static final String BODY       = "Body";
    static final String KEY        = "Key";

    //~ Instance fields --------------------------------------------------------

    // ~ Instance fields
    // --------------------------------------------------------
    @UiField FormBuilder ConManagementParameterForm;

    //~ Methods ----------------------------------------------------------------

    /**
     * This function is called by SDK infrastructure to initialize the UI parts
     * of this component.
     *
     * @return  A widget that the infrastructure should place in the UI; usually
     *          a panel.
     */
    @Override public Widget doInit()
    {
        Widget              base   = s_binder.createAndBindUi(this);
        final ValuedListBox Action = getUIFactory().createValuedListBox();

        // Add items to listbox View all, Add and Remove
        Action.addItem("View all", "view");
        Action.addItem("Add", "add");
        Action.addItem("Remove", "remove");
        ConManagementParameterForm.addRow(true, "Configuration:",
            "The name of the configuration that contains the information to connect with Heroku.",
            CONFIGNAME, "", new TextBox());
        ConManagementParameterForm.addRow(true, "Action:",
            "Select the Action to perform, the options are: View all, Add and Remove.",
            ACTION, "view", Action);
        ConManagementParameterForm.addRow(false, "Application Name:",
            "The name of the app to perform the action on.", APPNAME, "",
            new TextBox());
        ConManagementParameterForm.addRow(false, "Body:",
            "The new config vars, as a JSON hash.", BODY, "", new TextArea());
        ConManagementParameterForm.addRow(false, "Key:",
            "The name of the config var to remove.", KEY, "", new TextBox());
        Action.addValueChangeHandler(new ValueChangeHandler<String>() {
                @Override public void onValueChange(
                        ValueChangeEvent<String> event)
                {
                    updateRowVisibility();
                }
            });
        updateRowVisibility();

        return base;
    }

    /**
     * Performs validation of user supplied data before submitting the form.
     *
     * <p>This function is called after the user hits submit.</p>
     *
     * @return  true if checks succeed, false otherwise
     */
    @Override public boolean validate()
    {
        boolean validationStatus = ConManagementParameterForm.validate();
        String  action           = ConManagementParameterForm.getValue(ACTION);

        if (StringUtil.isEmpty(
                    ConManagementParameterForm.getValue(CONFIGNAME))) {
            ConManagementParameterForm.setErrorMessage(CONFIGNAME,
                "This Field is required.");
            validationStatus = false;
        }

        if (StringUtil.isEmpty(
                    ConManagementParameterForm.getValue(ACTION)
                                          .trim())) {
            ConManagementParameterForm.setErrorMessage(ACTION,
                "This Field is required.");
            validationStatus = false;
        }

        if ((!(action.equals("view")))
                && (StringUtil.isEmpty(
                        ConManagementParameterForm.getValue(APPNAME)
                                              .trim()))) {
            ConManagementParameterForm.setErrorMessage(APPNAME,
                "This Field is required.");
            validationStatus = false;
        }

        if ((action.equals("add"))
                && (StringUtil.isEmpty(
                        ConManagementParameterForm.getValue(BODY)
                                              .trim()))) {
            ConManagementParameterForm.setErrorMessage(BODY,
                "This Field is required.");
            validationStatus = false;
        }

        if ((action.equals("remove"))
                && (StringUtil.isEmpty(
                        ConManagementParameterForm.getValue(KEY)
                                              .trim()))) {
            ConManagementParameterForm.setErrorMessage(KEY,
                "This Field is required.");
            validationStatus = false;
        }

        return validationStatus;
    }

    /**
     * This method is used by UIBinder to embed FormBuilder's in the UI.
     *
     * @return  a new FormBuilder.
     */
    @UiFactory FormBuilder createFormBuilder()
    {
        return getUIFactory().createFormBuilder();
    }

    private void updateRowVisibility()
    {
        String action = ConManagementParameterForm.getValue(ACTION);

        ConManagementParameterForm.setRowVisible(APPNAME,
            !("view".equals(action)));
        ConManagementParameterForm.setRowVisible(BODY, "add".equals(action));
        ConManagementParameterForm.setRowVisible(KEY, "remove".equals(action));
    }

    /**
     * Straight forward function usually just return this;
     *
     * @return  straight forward function usually just return this;
     */
    @Override public ParameterPanel getParameterPanel()
    {
        return this;
    }

    /**
     * Gets the values of the parameters that should map 1-to-1 to the formal
     * parameters on the object being called. Transform user input into a map of
     * parameter names and values.
     *
     * <p>This function is called after the user hits submit and validation has
     * succeeded.</p>
     *
     * @return  The values of the parameters that should map 1-to-1 to the
     *          formal parameters on the object being called.
     */
    @Override public Map<String, String> getValues()
    {
        Map<String, String> actualParams     = new HashMap<String, String>();
        Map<String, String> searchFormValues = ConManagementParameterForm
                .getValues();

        actualParams.put(CONFIGNAME, searchFormValues.get(CONFIGNAME));
        actualParams.put(ACTION, searchFormValues.get(ACTION));
        actualParams.put(APPNAME, searchFormValues.get(APPNAME));
        actualParams.put(BODY, searchFormValues.get(BODY));
        actualParams.put(KEY, searchFormValues.get(KEY));

        return actualParams;
    }

    /**
     * Push actual parameters into the panel implementation.
     *
     * <p>This is used when editing an existing object to show existing content.
     * </p>
     *
     * @param  actualParameters  Actual parameters assigned to this list of
     *                           parameters.
     */
    @Override public void setActualParameters(
            Collection<ActualParameter> actualParameters)
    {

        // Store actual params into a hash for easy retrieval later
        if (actualParameters == null) {
            return;
        }

        // First load the parameters into a map. Makes it easier to
        // update the form by querying for various params randomly.
        Map<String, String> params = new HashMap<String, String>();

        for (ActualParameter p : actualParameters) {
            params.put(p.getName(), p.getValue());
        }

        // Do the easy form elements first.
        for (String key : new String[] {
                    CONFIGNAME,
                    ACTION,
                    APPNAME,
                    BODY,
                    KEY
                }) {
            ConManagementParameterForm.setValue(key,
                StringUtil.nullToEmpty(params.get(key)));
        }

        updateRowVisibility();
    }

    /**
     * Push form parameters into the panel implementation.
     *
     * <p>This is used when creating a new object and showing default values.
     * </p>
     *
     * @param  formalParameters  Formal parameters on the target object.
     */
    @Override public void setFormalParameters(
            Collection<FormalParameter> formalParameters) { }

    //~ Inner Interfaces -------------------------------------------------------

    interface Binder
        extends UiBinder<Widget, ConfigurationManagementParameterPanel> { }
}
