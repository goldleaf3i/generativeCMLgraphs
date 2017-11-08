%scriptino che ho usato per trovare le label "strane"

label_set = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
label_strane = [];

for i = 1:length(grafi)
  g = grafi{i};
  [r, c] = size(g);
  for j = 1:r
      tmp = any(label_set == g(j,j));
      if(tmp == 0)
          label_strane = [label_strane g(j,j)];
      end
  end
end

label_strane = unique(label_strane);
disp(label_strane);