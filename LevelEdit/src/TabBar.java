import javax.swing.JTabbedPane;

//creates JTabbedPane, Tabs
public class TabBar extends JTabbedPane
{

	//this is insignificant but apparently its needed because JFrame is serializable
	private static final long serialVersionUID = 1L;
	
	JTabbedPane tabs = new JTabbedPane();

	public TabBar()
	{
		
		TabGeneral tabGeneral = new TabGeneral();
		tabs.addTab("General", tabGeneral.scrollPane);
		
		TabDiseases tabDiseases = new TabDiseases();
		tabs.addTab("Diseases", tabDiseases.scrollPane);

		TabObjects tabObjects = new TabObjects();
		tabs.addTab("Objects", tabObjects.scrollPane);
		
		TabStaff tabStaff = new TabStaff();
		tabs.addTab("Staff", tabStaff.scrollPane);
		
		TabEmergencies tabEmergencies = new TabEmergencies();
		tabs.addTab("Emergencies", tabEmergencies.scrollPane);

		TabEarthquakes tabEarthquakes = new TabEarthquakes();
		tabs.addTab("Earthquakes", tabEarthquakes.scrollPane);

		TabPopulation tabPopulation = new TabPopulation();
		tabs.addTab("Population", tabPopulation.scrollPane);
		
		TabAwards tabAwards = new TabAwards();
		tabs.addTab("Awards", tabAwards.scrollPane);
		
		TabGoals tabGoals = new TabGoals();
		tabs.addTab("Goals", tabGoals.scrollPane);

	}
}
