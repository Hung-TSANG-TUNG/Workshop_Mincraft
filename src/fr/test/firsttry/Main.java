package fr.test.firsttry;
import org.bukkit.plugin.java.JavaPlugin;

public class Main extends JavaPlugin {
	@Override
	public void onEnable() {
		System.out.println("plugin start");
	}
	@Override
	public void onDisable() {
		System.out.println("shutdown plugin");
	}
}