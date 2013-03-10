import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;

import net.miginfocom.swing.MigLayout;


public class StaffLevels
{
	int month = 0;
	int nurses = 8;
	int doctors = 8;
	int handymen = 3;
	int receptionists = 2;
	int shrinkRate = 10;
	int surgeonRate = 10;
	int researcherRate = 10;
	int consultantRate = 10;
	int juniorRate = 5;
	
	JPanel staffLevelsPanel = new JPanel(new MigLayout());
	
	JLabel monthLabel = new JLabel("Starting from month:");
	JLabel nursesLabel = new JLabel("Nurses:");
	JLabel doctorsLabel = new JLabel("Doctors:");
	JLabel handymenLabel = new JLabel("Handymen:");
	JLabel receptionistsLabel = new JLabel("Receptionists:");
	JLabel shrinkRateLabel = new JLabel("Psychiatrist chance:");
	JLabel surgeonRateLabel = new JLabel("Surgeon chance:");
	JLabel researcherRateLabel = new JLabel("Researcher chance:");
	JLabel consultantRateLabel = new JLabel("Consultant chance:");
	JLabel juniorRateLabel = new JLabel("Junior chance:");
	
	JTextField monthTF = new JTextField("0", 3);
	JTextField nursesTF = new JTextField("8", 3);
	JTextField doctorsTF = new JTextField("8", 3);
	JTextField handymenTF = new JTextField("3", 3);
	JTextField receptionistsTF = new JTextField("2", 3);
	JTextField shrinkRateTF = new JTextField("1/10", 3);
	JTextField surgeonRateTF = new JTextField("1/10", 3);
	JTextField researcherRateTF = new JTextField("1/10", 3);
	JTextField consultantRateTF = new JTextField("1/10", 3);
	JTextField juniorRateTF = new JTextField("1/5", 3);
	
}
