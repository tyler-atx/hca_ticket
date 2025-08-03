CREATE EXTENSION plpython3u;

/* Add supplied functions as python procedural language
   Levenshtein distance counts edits.

   Some variable shuffling has to be performed due to issues with
   variable scoping in plpython
*/
CREATE FUNCTION hca_levenshtein_distance (sl1 text, sl2 text)
    RETURNS integer
AS $$
  s1 = sl1
  s2 = sl2
  if len(s1) < len(s2):
    s1 = sl2
    s2 = sl1
  previous_row = list(range(len(s2) + 1))
  for i, c1 in enumerate(s1):
    current_row = [i + 1]
    for j, c2 in enumerate(s2):
      insertions = previous_row[j + 1] + 1
      deletions = current_row[j] + 1
      substitutions = previous_row[j] + (c1 != c2)
      current_row.append(min(insertions, deletions, substitutions))
    previous_row = current_row
  return previous_row[-1]
$$ LANGUAGE plpython3u;

/* Provides an edit score as a ratio of the largest name.
   Otherwise, longer names would always have higher edit scores.
 */
CREATE FUNCTION hca_similarity_ratio (sr1 text, sr2 text)
    RETURNS float
AS $$
  s1 = sr1
  s2 = sr2
  if len(s1) < len(s2):
    s1 = sr2
    s2 = sr1
  previous_row = list(range(len(s2) + 1))
  for i, c1 in enumerate(s1):
    current_row = [i + 1]
    for j, c2 in enumerate(s2):
      insertions = previous_row[j + 1] + 1
      deletions = current_row[j] + 1
      substitutions = previous_row[j] + (c1 != c2)
      current_row.append(min(insertions, deletions, substitutions))
    previous_row = current_row
  max_len = max(len(s1), len(s2))
  return 1.0 if max_len == 0 else round(1.0 - previous_row[-1] / max_len, 2)
$$ LANGUAGE plpython3u;

/* Brute-force method of word matching in a sentence.
 */
CREATE FUNCTION hca_token_overlap_score(s1 text, s2 text)
    RETURNS float
AS $$
    tokens1 = set(s1.split())
    tokens2 = set(s2.split())
    return len(tokens1 & tokens2) / len(tokens1 | tokens2) if tokens1 and tokens2 else 0.0
$$ LANGUAGE plpython3u;
