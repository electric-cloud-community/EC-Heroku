
// ApplicationManagementParameterPanel.java --
//
// ApplicationManagementParameterPanel.java is part of ElectricCommander.
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
public class ApplicationManagementParameterPanel
    extends ComponentBase
    implements ParameterPanel,
        ParameterPanelProvider
{

    //~ Static fields/initializers ---------------------------------------------

    // ~ Static fields/initializers----------------------------
    private static UiBinder<Widget, ApplicationManagementParameterPanel> s_binder =
        GWT.create(Binder.class);

    // These are all the formalParameters on the Procedure
    static final String CONFIGNAME  = "ConfigName";
    static final String ACTION      = "Action";
    static final String APPNAME     = "AppName";
    static final String NEWAPPNAME  = "NewAppName";
    static final String STACK       = "Stack";
    static final String NEWAPPOWNER = "NewAppOwner";

    //~ Instance fields --------------------------------------------------------

    // ~ Instance fields
    // --------------------------------------------------------
    @UiField FormBuilder AppManagementParameterForm;

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

        // Add items to listbox
        Action.addItem("Create", "create");
        Action.addItem("Transfer", "transfer");
        Action.addItem("Rename", "rename");
        Action.addItem("Destroy", "destroy");
        AppManagementParameterForm.addRow(true, "Configuration:",
            "The name of the configuration that contains the information to connect with Heroku.",
            CONFIGNAME, "", new TextBox());
        AppManagementParameterForm.addRow(true, "Action:",
            "Select the Action to perform, the options are: Create, Transfer, Rename and Destroy.",
            ACTION, "create", Action);
        AppManagementParameterForm.addRow(false, "Application Name:",
            "The name of the app to perform the action on.", APPNAME, "",
            new TextBox());
        AppManagementParameterForm.addRow(false, "Stack:",
            "Allows to create an app on a stack, e.g. Bamboo.", STACK, "",
            new TextBox());
        AppManagementParameterForm.addRow(false, "New Owner:",
            "The new owner of the application.", NEWAPPOWNER, "",
            new TextBox());
        AppManagementParameterForm.addRow(false, "New Name:",
            "The new name of the application.", NEWAPPNAME, "", new TextBox());
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
        boolean validationStatus = AppManagementParameterForm.validate();
        String  action           = AppManagementParameterForm.getValue(ACTION);

        if (StringUtil.isEmpty(
                    AppManagementParameterForm.getValue(CONFIGNAME))) {
            AppManagementParameterForm.setErrorMessage(CONFIGNAME,
                "This Field is required.");
            validationStatus = false;
        }

        if (StringUtil.isEmpty(
                    AppManagementParameterForm.getValue(ACTION)
                                          .trim())) {
            AppManagementParameterForm.setErrorMessage(ACTION,
                "This Field is required.");
            validationStatus = false;
        }

        if ((!(action.equals("create")))
                && (StringUtil.isEmpty(
                        AppManagementParameterForm.getValue(APPNAME)
                                              .trim()))) {
            AppManagementParameterForm.setErrorMessage(APPNAME,
                "This Field is required.");
            validationStatus = false;
        }

        if ((action.equals("transfer"))
                && (StringUtil.isEmpty(
                        AppManagementParameterForm.getValue(NEWAPPOWNER)
                                              .trim()))) {
            AppManagementParameterForm.setErrorMessage(NEWAPPOWNER,
                "This Field is required.");
            validationStatus = false;
        }

        if ((action.equals("rename"))
                && (StringUtil.isEmpty(
                        AppManagementParameterForm.getValue(NEWAPPNAME)
                                              .trim()))) {
            AppManagementParameterForm.setErrorMessage(NEWAPPNAME,
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
        String action = AppManagementParameterForm.getValue(ACTION);

        AppManagementParameterForm.setRowVisible(NEWAPPNAME,
            "rename".equals(action));
        AppManagementParameterForm.setRowVisible(STACK,
            "create".equals(action));
        AppManagementParameterForm.setRowVisible(NEWAPPOWNER,
            "transfer".equals(action));
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
        Map<String, String> searchFormValues = AppManagementParameterForm
                .getValues();

        actualParams.put(CONFIGNAME, searchFormValues.get(CONFIGNAME));
        actualParams.put(ACTION, searchFormValues.get(ACTION));
        actualParams.put(APPNAME, searchFormValues.get(APPNAME));
        actualParams.put(STACK, searchFormValues.get(STACK));
        actualParams.put(NEWAPPOWNER, searchFormValues.get(NEWAPPOWNER));
        actualParams.put(NEWAPPNAME, searchFormValues.get(NEWAPPNAME));

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
                    STACK,
                    NEWAPPOWNER,
                    NEWAPPNAME
                }) {
            AppManagementParameterForm.setValue(key,
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
        extends UiBinder<Widget, ApplicationManagementParameterPanel> { }
}
