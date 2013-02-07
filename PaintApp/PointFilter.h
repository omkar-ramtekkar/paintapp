

#pragma once

#include <limits.h>
#include<limits>
#include "types.h"

#include <vector>
#include <map>




// Forward declaration because IPointFilter makes use of IPointFilterPtr
class IPointFilter;
typedef IPointFilter* IPointFilterPtr;

// Used for point filter parameters.  Allows for an int or float value, as well as a min & max for the value.
class CPointFilterParameter
{
public:
	typedef enum
	{
		VALUE_TYPE_NONE = 0,
		VALUE_TYPE_INT,
		VALUE_TYPE_FLOAT
	} ParameterValueType;
	
protected:
	ParameterValueType m_type;
	void *m_value;
	void *m_minValue;
	void *m_maxValue;

	void Initialize();

public:
	CPointFilterParameter();
	CPointFilterParameter(int value, int minValue = INT_MIN, int maxValue = INT_MAX);
	CPointFilterParameter(float value, float minValue = FLT_MIN, float maxValue = FLT_MAX);
	~CPointFilterParameter();

	ParameterValueType GetValueType() const;

	void SetIntValue(int value);
	int GetIntValue() const;
	void SetIntExtents(int minValue, int maxValue);
	int GetMinIntValue() const;
	int GetMaxIntValue() const;

	void SetFloatValue(float value);
	float GetFloatValue() const;
	void SetFloatExtents(float minValue, float maxValue);
	float GetMinFloatValue() const;
	float GetMaxFloatValue() const;

	void operator=(const CPointFilterParameter &param);
	bool operator==(const CPointFilterParameter &param);

};

// Point filter interface
class IPointFilter
{
protected:
	typedef enum
	{
		OUTPUT_TYPE_START = 0,
		OUTPUT_TYPE_MOVE,
		OUTPUT_TYPE_END
	} PointFilterOutputType;
	
	std::vector<PointF> m_outputBuffer;
	std::map<const std::string, CPointFilterParameter> m_parameterMap;
	IPointFilterPtr m_pPrevFilter;
	IPointFilterPtr m_pNextFilter;
	bool m_isEnabled;

	IPointFilter() : m_isEnabled(true) {}
	virtual ~IPointFilter() {}
	virtual void OutputPoint(float x, float y, PointFilterOutputType outType);

public:
	virtual void StartFilter(float x, float y);
	virtual void MoveFilter(float x, float y);
	virtual void EndFilter(float x, float y);

	void SetNextFilter(IPointFilterPtr pNextFilter);
	void SetPreviousFilter(IPointFilterPtr pPrevFilter);
	IPointFilterPtr GetNextFilter();
	IPointFilterPtr GetPreviousFilter();

	std::vector<PointF>& GetOutputBuffer();
	void ClearOutputBuffer();

	CPointFilterParameter *GetFilterParameter(const std::string &paramName);
	void SetFilterParameter(const std::string &paramName, const CPointFilterParameter &paramValue);
	std::map<const std::string, CPointFilterParameter> &GetFilterParameterMap();

	void SetEnabled(bool enabled);
	bool IsEnabled();
};

// Convenience class for creating a chain of point filters
class CPointFilterChain
{
protected:
	IPointFilterPtr m_pStartFilter;
	IPointFilterPtr m_pEndFilter;
	static std::vector<PointF> m_pEmptyBuffer;

public:
	CPointFilterChain();
	~CPointFilterChain();

	IPointFilterPtr GetStartFilter();
	IPointFilterPtr GetEndFilter();

	void AppendFilter(IPointFilterPtr pFilter);
	void InsertFilterAfter(IPointFilterPtr pPrevFilter, IPointFilterPtr pNewFilter);
	void InsertFilterBefore(IPointFilterPtr pPrevFilter, IPointFilterPtr pNewFilter);
	void RemoveFilter(IPointFilterPtr pFilter);

	void StartFilter(float x, float y);
	void MoveFilter(float x, float y);
	void EndFilter(float x, float y);

	std::vector<PointF>& GetOutputBuffer();
	void ClearOutputBuffer();

};

typedef CPointFilterChain* CPointFilterChainPtr;

// Simple passthrough filter (simply copies all input points to output)
class CPassthroughFilter : public IPointFilter
{
public:
	CPassthroughFilter() : IPointFilter() {}
	
};

// Moving exponential averaging filter
class CMovingExpAverageFilter : public IPointFilter
{
private:
	float m_x1, m_x2, m_x3, m_y1, m_y2, m_y3;

public:
	CMovingExpAverageFilter() : IPointFilter() {m_pPrevFilter = NULL;
		m_pNextFilter = NULL;}
	
	void StartFilter(float x, float y);
	void MoveFilter(float x, float y);
	void EndFilter(float x, float y);
	
};

// Collinear filter
class CCollinearFilter : public IPointFilter
{
public:
	static const std::string COLLINEAR_FILTER_PARAM_COSTHETA_THRESHOLD;
	static const std::string COLLINEAR_FILTER_PARAM_SEGMENT_LENGTH_THRESHOLD;

private:
	PointF m_ptA, m_ptB, m_ptC;
	float m_fLengthBA, m_fLengthBC;
	SizeF m_sizeBA, m_sizeBC;
	int m_count;
	float m_fCachedCosThetaThreshold;
	float m_fCachedLengthThreshold;

	// Used for filter stats
	int m_ptsIn, m_ptsOut;
	
public:
	CCollinearFilter();
	
	void StartFilter(float x, float y);
	void MoveFilter(float x, float y);
	void EndFilter(float x, float y);

};
