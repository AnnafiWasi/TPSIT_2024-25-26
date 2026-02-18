package org.example;

public class ThreadSomma extends Thread{
    int[][] result;
    int sum;
    public ThreadSomma(int[][] result) {
        this.result = result;
    }

    public void run(){
        for (int i = 0; i < result.length; i++){
            for (int j = 0; j < result.length; j++){
                sum = sum + result[i][j];
            }
        }
        System.out.print("\nSomma: " + sum);
    }
}

