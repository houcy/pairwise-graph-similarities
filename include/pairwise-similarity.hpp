
#ifndef __PAIRWISE_SIMILARITY_HPP__
#define __PAIRWISE_SIMILARITY_HPP__

#include <vector>
#include <map>
#include <utility>
#include <iostream>
#include <string>

#include <cstddef>

struct spgk_input_t;

class SimilarityMatrix {
  public:
    SimilarityMatrix(const std::string & cg_1_, const std::string & cg_2_, const std::string & feature_file, const std::string & path_);
    ~SimilarityMatrix();

    const std::vector<std::string> & getLabelsCG_1() const;
    size_t getIndex_1(const std::string & lbl) const;

    const std::vector<std::string> & getLabelsCG_2() const;
    size_t getIndex_2(const std::string & lbl) const;

    /// Compare all pairs
    virtual void evaluate();

    const float getSimilarity(const std::string & label_1, const std::string & label_2) const;
    float ** const getSimilarities() const;

    void dump(std::ostream & out) const;
    void printHTML(std::ostream & out) const;

  private:
    const std::string & path;

    const std::string & cg_1;
    std::vector<std::string> labels_1; /// Names of the routines of CG 1 

    const std::string & cg_2;
    std::vector<std::string> labels_2; /// Names of the routines of CG 2

    float ** similarity_matrix; /// 2D array, row major, dimensions: labels_1.length() * labels_2.length()

  protected:
    /// Mapping from labels to their indexes in labels_1
    std::map<std::string, size_t> map_lbl_1;

    /// Called by constructor after labels_1 is loaded
    virtual void sort_1();

    /// Mapping from labels to their indexes in labels_2
    std::map<std::string, size_t> map_lbl_2;

    /// Called by constructor after labels_2 is loaded
    virtual void sort_2();

  protected:
    /// Associate an index to each feature
    std::map<std::string, size_t> feature_dictionary;
    size_t getFeatureIdx(const std::string & feature_name) const;

    void loadFeatureNames(const std::string & feature_name_file);

  protected:
    std::map<std::string, spgk_input_t *> routines_map;
    spgk_input_t * getCFG(const std::string & cg, const std::string & routine);
    void freeCFG(const std::string & cg, const std::string & routine);

/*protected:
    SimilarityMatrix * extract(const std::vector<std::string> & lbl_1_subset, const std::vector<std::string> & lbl_2_subset) const;
    void contribute(SimilarityMatrix * similarity_matrix);*/
};

#endif /*  __PAIRWISE_SIMILARITY_HPP__ */

