// Checks the return capabilities and passing multiple parameters to a function 

int prints(char *c);
int printi(int i);

int inc(int a,int b){
  prints("\n\nJust Entered into the function \n");
  b=b+5+a;
  prints("Return Value : ");
  printi(b);
  return b;
}

int main() {
  int i,j=10;
  i=1;
  prints("Now entering the function ....3...2...1... \n");
  j=inc(i,j);
  prints("\n\nThe value returned from the function is \n");
  printi(j);

  prints("\n");

  prints("\n\nMission_complete..\n");
  return 0;
}
