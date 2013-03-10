import javax.swing.JCheckBox;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;

import net.miginfocom.swing.MigLayout;


public class StartStaff
{
	int doctor = 1;
	int shrink= 0;
	int surgeon= 0;
	int researcher= 0;
	int nurse= 0;
	int handyman= 0;
	int receptionist= 0;
	int skill = 50;
	String[] staffChoice = {"Doctor", "Nurse", "Handyman", "Receptionist"};
	
	JPanel startStaffPanel = new JPanel(new MigLayout("insets 1"));
	
	JComboBox staffMemberCombo = new JComboBox(staffChoice);
	JCheckBox shrinkCB = new JCheckBox();
	JCheckBox surgeonCB = new JCheckBox();
	JCheckBox researcherCB = new JCheckBox();
	JLabel shrinkLabel = new JLabel("Psychiatrist");
	JLabel surgeonLabel = new JLabel("Surgeon");
	JLabel researcherLabel = new JLabel("Researcher");
	JLabel skillLabel = new JLabel("Skill");
	JTextField skillTF = new JTextField("50", 5);
	
}
