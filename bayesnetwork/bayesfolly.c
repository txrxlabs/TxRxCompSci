#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>

#if 1
#define MAXWORDS 150000
#else
#define MAXWORDS 5
#endif

#define NLETTERS 27

struct probability_table_entry {
	int count;
  double freq;
	struct probability_table_entry *child;
}; 

#define ARRAYSIZE(x) (sizeof(x) / sizeof(x[0]))

void read_file(char *filename, char **contents)
{
	int fd, n;
	struct stat s;
	off_t bytesleft;
  int i;

	fd = open(filename, O_RDONLY);
	if (fd < 0) {
		fprintf(stderr, "open: %s\n", strerror(errno));
		exit(1);
	}

	fstat(fd, &s);

	bytesleft = s.st_size;

	*contents = malloc(s.st_size);

	n = read(fd, *contents, s.st_size);
	if (n != s.st_size) {
		fprintf(stderr, "Failed to read file: %s\n", strerror(errno));
		exit(1);
	}
			
	printf("Read %llu bytes\n", (unsigned long long) s.st_size);

  for(i = 0; i < n; i++){
    (*contents)[i] = tolower((*contents)[i]);
  }

	close(fd);
}

void break_into_words(char *contents, char *word[], int maxwords, int *nwords)
{
	char *x;
	int i;
	char *delimiters = " 	:0123456789[]/\\$@%*#-;,.!?()'';\"\n";

	i = 0;
	x = strtok(contents, delimiters);
	do {
		word[i] = x;
		x = strtok(NULL, delimiters);
		if (x && strcmp(x, "") == 0)
			continue;
		i++;
	} while (x != NULL && i < maxwords);
	printf("processed %d words\n", i);
	*nwords = i;

  /* print all words after reading in
	for (i = 0; i < *nwords; i++)
		printf("'%s'\n", word[i]);
  */
}

void load_word_count(char *word, struct probability_table_entry *children) {
  char *c;
  c = word;

  while(*c) {
    if (*c < 'a' || *c > 'z')
      printf("NON-ALPHA CHAR: %c\n", *c );
    children[*c - 'a'].count++;
    if ( !children[*c - 'a'].child ) {
      children[*c - 'a'].child = calloc(NLETTERS, sizeof(*children));
    }
    children = children[*c - 'a'].child;
    c++;
  }
  children[26].count++;
  return;
}

void load_counts(char *words[], int nwords, struct probability_table_entry toplevel[])
{
  int i;
  for (i=0; i < nwords; i++) {
    load_word_count(words[i], toplevel);
  }
}

void print_counts(struct probability_table_entry *children, int level, char parent) 
{

  int i,j;

  if (!children) {
    return;
  }

  for (i=0;i<NLETTERS;i++){
    for(j=0;j<level;j++) {printf(" ");}
    printf("L%02dC%c %c: %d\n", level, parent, i+'a', children[i].count);
    print_counts(children[i].child, level+1, i+'a');
  }

}

void calc_freqs(struct probability_table_entry *children) {
  int sum,i;

  if (!children) {
    return;
  }
  sum=0;
  for(i=0;i<NLETTERS;i++) {
    sum+=children[i].count;
  }
  for(i=0;i<NLETTERS;i++){
    children[i].freq = children[i].count / (1.0*sum);
    calc_freqs(children[i].child);
  }
}

void print_freqs(struct probability_table_entry *children, int level, char parent) 
{
  int i,j;
  double sum=0;

  if (!children) {
    return;
  }

  for (i=0;i<NLETTERS;i++){
    for(j=0;j<level;j++)
      printf(" ");
    printf("FREQ:L%02dC%c %c: %f\n", level, parent, i+'a', children[i].freq);
    sum += children[i].freq;
    print_freqs(children[i].child, level+1, i+'a');
  }
  printf("FREQ:SUM L%02dC%c: %f\n", level, parent, sum);
}

struct pwc {
	double prob;
	char* seq;
};

struct pwc getRMW(char me,struct probability_table_entry *tl);

//prefix must be null terminated
char* return_max_prob_word(char* prefix, struct probability_table_entry *tl) 
{
	char *tmp;
	struct pwc p;

	while(*prefix) {
		tl=tl[*prefix-'a'].child;
		tmp = prefix;
		prefix++;
	}
	p = getRMW(*tmp, tl); 
	return p.seq;
}  
  

char *string_append(char *string1, char *string2)
{
	int len1, len2;
	char *string3;

	len1 = strlen(string1);
	len2 = strlen(string2);

	string3 = malloc(len1 + len2 + 1);
	strcpy(string3, string1);
	strcat(string3, string2);
	return string3;
}

struct pwc getRMW(char me, struct probability_table_entry *tl) 
{

	char x[2];
	double mp=-1;
	char *seq;
	int i;
	for(i=0;i<27;i++) {
		if(i==26 && mp<tl->freq) {
			printf("terminal probability = %f\n", tl->freq);
			seq=malloc(sizeof(2));
			*seq=me;
			*(seq+1) = '\0';
			struct pwc *pwcd = malloc(sizeof(struct pwc));
			pwcd->prob=tl->freq;
			pwcd->seq=seq;
		}
		if(tl[i].child==NULL) continue;
		struct pwc pwci = getRMW(i+'a',tl[i].child);
		if(pwci.prob>mp) {
			mp = pwci.prob;
			 seq = pwci.seq;
		} 
	}

//mult pwc prob time my prob and then append char to begining and return

	x[0] = me;
	x[1] = '\0';	

	seq = string_append(x, seq);

	struct pwc *pwcd = malloc(sizeof(struct pwc));
	pwcd->prob=tl->freq*mp;
	pwcd->seq=seq;
	printf("Returning '%s', prob=%f\n", pwcd->seq, pwcd->prob);
	return *pwcd;
}


int main(int argc, char *argv[])
{
	struct probability_table_entry toplevel[NLETTERS];
	char *contents;
	char *words[MAXWORDS];
	int nwords, i;

	memset(toplevel, 0, sizeof(toplevel));
	memset(words, 0, sizeof(words));
	read_file("huckfinn.txt", &contents);

	break_into_words(contents, words, ARRAYSIZE(words), &nwords);

	/* count words & determine frequency */

	load_counts(words, nwords, toplevel);
	// print_counts(toplevel, 0, 'T');
	calc_freqs(toplevel);
	// print_freqs(toplevel, 0, 'T');

	printf("%s\n", return_max_prob_word("ji", toplevel));

	return 0;
}
