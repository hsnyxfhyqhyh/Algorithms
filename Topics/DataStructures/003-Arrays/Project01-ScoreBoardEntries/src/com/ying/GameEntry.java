package com.ying;

public class GameEntry {
	private String name;
	private int score;
	
	public String getName() {
		return name;
	}

	public int getScore() {
		return score;
	}
	
	public GameEntry(String name, int score) {
		super();
		this.name = name;
		this.score = score;
	}

	@Override
	public String toString() {
		return "GameEntry [name=" + name + ", score=" + score + "]";
	} 
	

	
}
