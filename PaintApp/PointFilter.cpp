
#include "PointFilter.h"
#include <string>

// ------ CPointFilterParameter ------

CPointFilterParameter::CPointFilterParameter()
{
	Initialize();
}

CPointFilterParameter::CPointFilterParameter(int value, int minValue, int maxValue)
{
	Initialize();
	SetIntExtents(minValue, maxValue);
	SetIntValue(value);
}

CPointFilterParameter::CPointFilterParameter(float value, float minValue, float maxValue)
{
	Initialize();
	SetFloatExtents(minValue, maxValue);
	SetFloatValue(value);
}

CPointFilterParameter::~CPointFilterParameter()
{

	if (m_value)
	{
		free(m_value);
		free(m_minValue);
		free(m_maxValue);
		m_value = NULL;
		m_minValue = NULL;
		m_maxValue = NULL;
		m_type = VALUE_TYPE_NONE;
	}

}

void CPointFilterParameter::Initialize()
{
	m_value = NULL;
	m_minValue = NULL;
	m_maxValue = NULL;
	m_type = VALUE_TYPE_NONE;
}

CPointFilterParameter::ParameterValueType CPointFilterParameter::GetValueType() const
{
	return m_type;
}

void CPointFilterParameter::SetIntValue(int value)
{

	if (m_type == VALUE_TYPE_INT)
	{
		int curValue = *((int*)m_value);
		int curMinValue = *((int*)m_minValue);
		int curMaxValue = *((int*)m_maxValue);

		if (curValue == value)
		{
			return;
		}

		if ( (value < curMinValue) || (value > curMaxValue) )
		{
			return;
		}

		memcpy(m_value, &value, sizeof(int));
	}
	else
	{

		if (m_value)
		{
			free(m_value);
			free(m_minValue);
			free(m_maxValue);
		}

		int minVal = INT_MIN, maxVal = INT_MAX;

		m_type = VALUE_TYPE_INT;
		m_value = malloc(sizeof(int));
		m_minValue = malloc(sizeof(int));
		m_maxValue = malloc(sizeof(int));
		memcpy(m_value, &value, sizeof(int));
		memcpy(m_minValue, &minVal, sizeof(int));
		memcpy(m_maxValue, &maxVal, sizeof(int));
	}

}

int CPointFilterParameter::GetIntValue() const
{

	switch (m_type)
	{
		case VALUE_TYPE_INT:
			return *((int*)m_value);
		case VALUE_TYPE_FLOAT:
			return (int)(*((float*)m_value) + 0.5f);
		case VALUE_TYPE_NONE:
		default:
			break;
	}

	return 0;
}

void CPointFilterParameter::SetIntExtents(int minValue, int maxValue)
{

	if (m_type == VALUE_TYPE_INT)
	{
		int curValue = *((int*)m_value);
		int curMinValue = *((int*)m_minValue);
		int curMaxValue = *((int*)m_maxValue);

		if (minValue != curMinValue)
		{
			memcpy(m_minValue, &minValue, sizeof(int));
		}

		if (maxValue != curMaxValue)
		{
			memcpy(m_maxValue, &maxValue, sizeof(int));
		}

		if (curValue < minValue)
		{
			memcpy(m_value, m_minValue, sizeof(int));
		}
		else if (curValue > maxValue)
		{
			memcpy(m_value, m_maxValue, sizeof(int));
		}

	}
	else
	{
		int oldVal = GetIntValue();

		if (oldVal < minValue)
		{
			oldVal = minValue;
		}
		else if (oldVal > maxValue)
		{
			oldVal = maxValue;
		}

		if (m_value)
		{
			free(m_value);
			free(m_minValue);
			free(m_maxValue);
		}
		
		m_type = VALUE_TYPE_INT;
		m_value = malloc(sizeof(int));
		m_minValue = malloc(sizeof(int));
		m_maxValue = malloc(sizeof(int));
		
		memcpy(m_minValue, &minValue, sizeof(int));
		memcpy(m_maxValue, &maxValue, sizeof(int));
		memcpy(m_value, &oldVal, sizeof(int));
	}
	
}

int CPointFilterParameter::GetMinIntValue() const
{

	switch (m_type)
	{
		case VALUE_TYPE_INT:
			return *((int*)m_minValue);
		case VALUE_TYPE_FLOAT:
			return (int)(*((float*)m_minValue) + 0.5f);
		case VALUE_TYPE_NONE:
		default:
			break;
	}

	return INT_MIN;
}

int CPointFilterParameter::GetMaxIntValue() const
{
	
	switch (m_type)
	{
		case VALUE_TYPE_INT:
			return *((int*)m_maxValue);
		case VALUE_TYPE_FLOAT:
			return (int)(*((float*)m_maxValue) + 0.5f);
		case VALUE_TYPE_NONE:
		default:
			break;
	}
	
	return INT_MAX;
}

void CPointFilterParameter::SetFloatValue(float value)
{
	
	if (m_type == VALUE_TYPE_FLOAT)
	{
		float curValue = *((float*)m_value);
		float curMinValue = *((float*)m_minValue);
		float curMaxValue = *((float*)m_maxValue);

		if (curValue == value)
		{
			return;
		}
		
		if ( (value < curMinValue) || (value > curMaxValue) )
		{
			return;
		}
		
		memcpy(m_value, &value, sizeof(float));
	}
	else
	{
		
		if (m_value)
		{
			free(m_value);
			free(m_minValue);
			free(m_maxValue);
		}
		
		float minVal = FLT_MIN, maxVal = FLT_MAX;
		m_type = VALUE_TYPE_FLOAT;
		m_value = malloc(sizeof(float));
		m_minValue = malloc(sizeof(float));
		m_maxValue = malloc(sizeof(float));
		memcpy(m_value, &value, sizeof(int));
		memcpy(m_minValue, &minVal, sizeof(float));
		memcpy(m_maxValue, &maxVal, sizeof(float));
	}
	
}

float CPointFilterParameter::GetFloatValue() const
{
	
	switch (m_type)
	{
		case VALUE_TYPE_INT:
			return (float)(*((int*)m_value));
		case VALUE_TYPE_FLOAT:
			return *((float*)m_value);
		case VALUE_TYPE_NONE:
		default:
			break;
	}
	
	return 0.0f;
}

void CPointFilterParameter::SetFloatExtents(float minValue, float maxValue)
{

	if (m_type == VALUE_TYPE_FLOAT)
	{
		float curValue = *((float*)m_value);
		float curMinValue = *((float*)m_minValue);
		float curMaxValue = *((float*)m_maxValue);
		
		if (minValue != curMinValue)
		{
			memcpy(m_minValue, &minValue, sizeof(float));
		}
		
		if (maxValue != curMaxValue)
		{
			memcpy(m_maxValue, &maxValue, sizeof(float));
		}
		
		if (curValue < minValue)
		{
			memcpy(m_value, m_minValue, sizeof(float));
		}
		else if (curValue > maxValue)
		{
			memcpy(m_value, m_maxValue, sizeof(float));
		}
		
	}
	else
	{
		float oldVal = GetFloatValue();

		if (oldVal < minValue)
		{
			oldVal = minValue;
		}
		else if (oldVal > maxValue)
		{
			oldVal = maxValue;
		}
		
		if (m_value)
		{
			free(m_value);
			free(m_minValue);
			free(m_maxValue);
		}
		
		m_type = VALUE_TYPE_FLOAT;
		m_value = malloc(sizeof(float));
		m_minValue = malloc(sizeof(float));
		m_maxValue = malloc(sizeof(float));
		
		memcpy(m_minValue, &minValue, sizeof(float));
		memcpy(m_maxValue, &maxValue, sizeof(float));
		memcpy(m_value, &oldVal, sizeof(float));
	}
	
}

float CPointFilterParameter::GetMinFloatValue() const
{
	
	switch (m_type)
	{
		case VALUE_TYPE_INT:
			return (float)(*((int*)m_minValue));
		case VALUE_TYPE_FLOAT:
			return *((float*)m_minValue);
		case VALUE_TYPE_NONE:
		default:
			break;
	}

	return FLT_MIN;
}

float CPointFilterParameter::GetMaxFloatValue() const
{
	
	switch (m_type)
	{
		case VALUE_TYPE_INT:
			return (float)(*((int*)m_maxValue));
		case VALUE_TYPE_FLOAT:
			return *((float*)m_maxValue);
		case VALUE_TYPE_NONE:
		default:
			break;
	}

	return FLT_MAX;
}

void CPointFilterParameter::operator=(const CPointFilterParameter &param)
{

	switch (param.GetValueType())
	{
		case VALUE_TYPE_INT:
			SetIntExtents(param.GetMinIntValue(), param.GetMaxIntValue());
			SetIntValue(param.GetIntValue());
			break;
		case VALUE_TYPE_FLOAT:
			SetFloatExtents(param.GetMinFloatValue(), param.GetMaxFloatValue());
			SetFloatValue(param.GetFloatValue());
			break;
		case VALUE_TYPE_NONE:

			if (m_value)
			{
				free(m_value);
				free(m_minValue);
				free(m_maxValue);
				m_value = NULL;
				m_minValue = NULL;
				m_maxValue = NULL;
			}
			
			m_type = VALUE_TYPE_NONE;
			break;
		default:
			break;
	}

}

bool CPointFilterParameter::operator==(const CPointFilterParameter &param)
{

	if (m_type != param.GetValueType())
	{
		return false;
	}

	switch (m_type)
	{
		case VALUE_TYPE_INT:

			if (GetIntValue() == param.GetIntValue())
			{
				return true;
			}

			break;
		case VALUE_TYPE_FLOAT:
			
			if (GetFloatValue() == param.GetFloatValue())
			{
				return true;
			}
			
			break;
		case VALUE_TYPE_NONE:
			return true;
		default:
			break;
	}

	return false;
}

// ------ CPointFilterChain ------

std::vector<PointF> CPointFilterChain::m_pEmptyBuffer;

CPointFilterChain::CPointFilterChain()
{
	m_pStartFilter = NULL;
	m_pEndFilter = NULL;
}

CPointFilterChain::~CPointFilterChain()
{
	IPointFilterPtr pTempFilter = GetEndFilter();
	while( pTempFilter)
	{
		RemoveFilter(pTempFilter);
		pTempFilter = GetStartFilter();
	}
}

IPointFilterPtr CPointFilterChain::GetStartFilter()
{
	return m_pStartFilter;
}

IPointFilterPtr CPointFilterChain::GetEndFilter()
{
	return m_pEndFilter;
}

void CPointFilterChain::AppendFilter(IPointFilterPtr pFilter)
{

	if (!m_pStartFilter)
	{
		m_pStartFilter = pFilter;
		m_pEndFilter = pFilter;
		return;
	}

	IPointFilterPtr pPrevFilter = m_pStartFilter;
	IPointFilterPtr pCurFilter = m_pStartFilter->GetNextFilter();

	while (pCurFilter)
	{
		pPrevFilter = pCurFilter;
		pCurFilter = pPrevFilter->GetNextFilter();
	}

	pPrevFilter->SetNextFilter(pFilter);
	m_pEndFilter = pFilter;
}

void CPointFilterChain::InsertFilterAfter(IPointFilterPtr pPrevFilter, IPointFilterPtr pNewFilter)
{
	
	if (!pPrevFilter || !pNewFilter)
	{
		return;
	}
	
	IPointFilterPtr pCurFilter = m_pStartFilter;
	
	while (pCurFilter && (pCurFilter != pPrevFilter))
	{
		pCurFilter = pCurFilter->GetNextFilter();
	}
	
	if (pCurFilter)
	{
		IPointFilterPtr pNextFilter = pCurFilter->GetNextFilter();
		pCurFilter->SetNextFilter(pNewFilter);

		if (pNextFilter)
		{
			pNewFilter->SetNextFilter(pNextFilter);
		}
		else
		{
			m_pEndFilter = pNewFilter;
		}

	}

}

void CPointFilterChain::InsertFilterBefore(IPointFilterPtr pPrevFilter, IPointFilterPtr pNewFilter)
{
	
	if (!pPrevFilter || !pNewFilter)
	{
		return;
	}
	
	IPointFilterPtr pCurFilter = m_pStartFilter;
	
	while (pCurFilter && (pCurFilter != pPrevFilter))
	{
		pCurFilter = pCurFilter->GetNextFilter();
	}
	
	if (pCurFilter)
	{
		IPointFilterPtr pPrevFilter = pCurFilter->GetPreviousFilter();
		pCurFilter->SetPreviousFilter(pNewFilter);

		if (pPrevFilter)
		{
			pNewFilter->SetPreviousFilter(pPrevFilter);
		}
		else
		{
			m_pStartFilter = pNewFilter;
		}
		
	}
	
}

void CPointFilterChain::RemoveFilter(IPointFilterPtr pFilter)
{

	if (!pFilter)
	{
		return;
	}

	IPointFilterPtr pCurFilter = m_pStartFilter;

	while (pCurFilter && (pCurFilter != pFilter))
	{
		pCurFilter = pCurFilter->GetNextFilter();
	}

	if (pCurFilter)
	{
		IPointFilterPtr pPrevFilter = pCurFilter->GetPreviousFilter();
		IPointFilterPtr pNextFilter = pCurFilter->GetNextFilter();

		if (pPrevFilter)
		{
			pPrevFilter->SetNextFilter(pNextFilter);
		}
		else
		{
			m_pStartFilter = pNextFilter;
		}

		if (!pNextFilter)
		{
			m_pEndFilter = pPrevFilter;
		}

	}

}

void CPointFilterChain::StartFilter(float x, float y)
{

	if (m_pStartFilter)
	{
		m_pStartFilter->StartFilter(x, y);
	}

}

void CPointFilterChain::MoveFilter(float x, float y)
{
	
	if (m_pStartFilter)
	{
		m_pStartFilter->MoveFilter(x, y);
	}
	
}

void CPointFilterChain::EndFilter(float x, float y)
{
	
	if (m_pStartFilter)
	{
		m_pStartFilter->EndFilter(x, y);
	}
	
}

std::vector<PointF>& CPointFilterChain::GetOutputBuffer()
{

	if (m_pEndFilter)
	{
		return m_pEndFilter->GetOutputBuffer();
	}

	return m_pEmptyBuffer;
}

void CPointFilterChain::ClearOutputBuffer()
{
	
	if (m_pEndFilter)
	{
		return m_pEndFilter->ClearOutputBuffer();
	}
	
}

// ------ IPointFilter ------

void IPointFilter::StartFilter(float x, float y)
{
	ClearOutputBuffer();
	OutputPoint(x, y, OUTPUT_TYPE_START);
}

void IPointFilter::MoveFilter(float x, float y)
{
	OutputPoint(x, y, OUTPUT_TYPE_MOVE);
}

void IPointFilter::EndFilter(float x, float y)
{
	OutputPoint(x, y, OUTPUT_TYPE_END);
}

void IPointFilter::SetNextFilter(IPointFilterPtr pNextFilter)
{ 

	// Prevents recursion from SetNext and SetPrevious calls
	if (m_pNextFilter == pNextFilter)
	{
		return;
	}

	m_pNextFilter = pNextFilter;

	if (m_pNextFilter)
	{
		m_pNextFilter->SetPreviousFilter(this);
	}

}

void IPointFilter::SetPreviousFilter(IPointFilterPtr pPrevFilter)
{

	// Prevents recursion from SetNext and SetPrevious calls
	if (m_pPrevFilter == pPrevFilter)
	{
		return;
	}

	m_pPrevFilter = pPrevFilter;

	if (m_pPrevFilter)
	{
		m_pPrevFilter->SetNextFilter(this);
	}

}

IPointFilterPtr IPointFilter::GetNextFilter()
{
	return m_pNextFilter;
}

IPointFilterPtr IPointFilter::GetPreviousFilter()
{
	return m_pPrevFilter;
}

std::vector<PointF>& IPointFilter::GetOutputBuffer()
{
	return m_outputBuffer;
}

void IPointFilter::ClearOutputBuffer()
{
	m_outputBuffer.clear();
}

void IPointFilter::OutputPoint(float x, float y, PointFilterOutputType outType)
{

	switch (outType)
	{
		case OUTPUT_TYPE_START:

			if (m_pNextFilter)
			{
				m_pNextFilter->StartFilter(x, y);
			}
			else
			{
				m_outputBuffer.push_back(PointF(x, y));
			}

			break;
		case OUTPUT_TYPE_MOVE:
			
			if (m_pNextFilter)
			{
				m_pNextFilter->MoveFilter(x, y);
			}
			else
			{
				m_outputBuffer.push_back(PointF(x, y));
			}
			
			break;
		case OUTPUT_TYPE_END:
			
			if (m_pNextFilter)
			{
				m_pNextFilter->EndFilter(x, y);
			}
			else
			{
				m_outputBuffer.push_back(PointF(x, y));
			}
			
			break;
		default:
			break;
	}

}

CPointFilterParameter *IPointFilter::GetFilterParameter(const std::string &paramName)
{
	std::map<const std::string, CPointFilterParameter>::iterator it = m_parameterMap.find(paramName);

	if (it != m_parameterMap.end())
	{
		return &(it->second);
	}

	return NULL;
}

std::map<const std::string, CPointFilterParameter> &IPointFilter::GetFilterParameterMap()
{
	return m_parameterMap;
}

void IPointFilter::SetFilterParameter(const std::string &paramName, const CPointFilterParameter &paramValue)
{
	m_parameterMap[paramName] = paramValue;
}

void IPointFilter::SetEnabled(bool enabled)
{
	m_isEnabled = enabled;
}

bool IPointFilter::IsEnabled()
{
	return m_isEnabled;
}

// ------ CMovingExpAverageFilter ------

void CMovingExpAverageFilter::StartFilter(float x, float y)
{

	if (!m_isEnabled)
	{
		IPointFilter::StartFilter(x, y);
		return;
	}

	m_x1 = m_x2 = m_x3 = x * 9.0f;
	m_y1 = m_y2 = m_y3 = y * 9.0f;
	ClearOutputBuffer();
	OutputPoint(x, y, OUTPUT_TYPE_START);
}

// 2007-01-12 djohnston:  Made some optimizations to the point filtering code.
void CMovingExpAverageFilter::MoveFilter( float x, float y )
{
	
	if (!m_isEnabled)
	{
		IPointFilter::MoveFilter(x, y);
		return;
	}
	
	m_x3 = 9.0f * x;
	m_y3 = 9.0f * y;
	
	PointF pt0, pt1, pt2;
	pt0.X = ((2.0f * m_x1) + m_x2) / 27.0f;
	pt0.Y = ((2.0f * m_y1) + m_y2) / 27.0f;
	pt1.X = ((4.0f * (m_x1 + m_x2)) + m_x3) / 81.0f;
	pt1.Y = ((4.0f * (m_y1 + m_y2)) + m_y3) / 81.0f;
	m_x1 = ((8.0f * (m_x1 + m_x3)) + (11.0f * m_x2)) / 27.0f;
	pt2.X = m_x1 / 9.0f;
	m_y1 = ((8.0f * (m_y1 + m_y3)) + (11.0f * m_y2)) / 27.0f;
	pt2.Y = m_y1 / 9.0f;
	
	m_x2 = m_x3;
	m_y2 = m_y3;

	ClearOutputBuffer();
	OutputPoint(pt0.X, pt0.Y, OUTPUT_TYPE_MOVE);
	OutputPoint(pt1.X, pt1.Y, OUTPUT_TYPE_MOVE);
	OutputPoint(pt2.X, pt2.Y, OUTPUT_TYPE_MOVE);
}

void CMovingExpAverageFilter::EndFilter(float x, float y)
{
	
	if (!m_isEnabled)
	{
		IPointFilter::EndFilter(x, y);
		return;
	}
	
	MoveFilter(x, y);
	
	if (m_pNextFilter)
	{
		m_pNextFilter->EndFilter(x, y);
	}
	else
	{
		m_outputBuffer[2].X = x;
		m_outputBuffer[2].Y = y;
	}
	
}

// ------ CCollinearFilter ------

const std::string CCollinearFilter::COLLINEAR_FILTER_PARAM_COSTHETA_THRESHOLD = "Maximum cos(theta) Value";
const std::string CCollinearFilter::COLLINEAR_FILTER_PARAM_SEGMENT_LENGTH_THRESHOLD = "Maximum Segment Length";

CCollinearFilter::CCollinearFilter() : IPointFilter()
{
#define kDefaultCosThetaThreshold			-0.975f
#define kDefaultSegmentLengthThreshold		5.0f
	m_pPrevFilter = NULL;
	m_pNextFilter = NULL;
	SetFilterParameter(COLLINEAR_FILTER_PARAM_COSTHETA_THRESHOLD,
					   CPointFilterParameter(kDefaultCosThetaThreshold, -1.0f, 1.0f));
	SetFilterParameter(COLLINEAR_FILTER_PARAM_SEGMENT_LENGTH_THRESHOLD,
					   CPointFilterParameter(kDefaultSegmentLengthThreshold, 0.0f, 100.0f));
}

void CCollinearFilter::StartFilter(float x, float y)
{
	
	if (!m_isEnabled)
	{
		IPointFilter::StartFilter(x, y);
		return;
	}
	
	ClearOutputBuffer();
	m_ptA.X = x;
	m_ptA.Y = y;
	m_count = 1;
	m_fCachedCosThetaThreshold = GetFilterParameter(COLLINEAR_FILTER_PARAM_COSTHETA_THRESHOLD)->GetFloatValue();
	m_fCachedLengthThreshold = GetFilterParameter(COLLINEAR_FILTER_PARAM_SEGMENT_LENGTH_THRESHOLD)->GetFloatValue();
	OutputPoint(x, y, OUTPUT_TYPE_START);

	m_ptsIn = 1;
	m_ptsOut = 1;
}

void CCollinearFilter::MoveFilter(float x, float y)
{
	
	if (!m_isEnabled)
	{
		IPointFilter::MoveFilter(x, y);
		return;
	}
	
	m_ptsIn++;
	
	if (m_count == 1)
	{
		m_ptB.X = x;
		m_ptB.Y = y;
		m_sizeBA.Width = m_ptA.X - m_ptB.X;
		m_sizeBA.Height = m_ptA.Y - m_ptB.Y;
		m_fLengthBA = sqrtf(powf(m_sizeBA.Width, 2.0f) + powf(m_sizeBA.Height, 2.0f));
		m_count = 2;
	}
	else
	{
		m_ptC.X = x;
		m_ptC.Y = y;
		
		// calculate the x and y components of vector BC
		m_sizeBC.Width = m_ptC.X - m_ptB.X;
		m_sizeBC.Height = m_ptC.Y - m_ptB.Y;
		
		// calculate length of vector BC (always positive)
		m_fLengthBC = sqrtf(powf(m_sizeBC.Width, 2.0f) + powf(m_sizeBC.Height, 2.0f));
		
		// calculate the absolute size of vector AC
		SizeF absSizeAC(fabs(m_ptC.X - m_ptA.X), fabs(m_ptC.Y - m_ptA.Y));
		
		// calculate the dot product of vector BA and BC
		float fDotBABC = (m_sizeBA.Width * m_sizeBC.Width) + (m_sizeBA.Height * m_sizeBC.Height);
		
		// Calculate cos(theta). To filter out duplicate points and avoid 
		// division by zero just set fCosTheta to -1 so that B will always be 
		// filtered out.
		float fCosTheta;
		
		if (nearf(m_ptB, m_ptA) || nearf(m_ptB, m_ptC))
		{
			fCosTheta = -1.0f;
		}
		else
		{
			fCosTheta = fDotBABC / (m_fLengthBA * m_fLengthBC);
		}

        // If fCosTheta is between -1 and the threshold, the points are near 
		// collinear so filter them out. But not if vector AC would be longer 
		// than the size threshold.
		if ( (fCosTheta <= m_fCachedCosThetaThreshold) &&
			 (absSizeAC.Width <= m_fCachedLengthThreshold) && (absSizeAC.Height <= m_fCachedLengthThreshold) )
		{
			// Near collinear, filter out point B
			
			// Recalculate the x and y components of vector BA.
			// No! Do not recalculate this vector! This solves the problem
			// of too many points being filtered out in a parabolic curve.
			// And it speeds up the code. Bonus! However this means that the 
			// filter should only be run once on a path because if it run a
			// second time it will filter out more points. 
			// CoreyN 2004-03-11.
			//
			// Ok, we still need to recalculate this vector if point A == B. 
			// Otherwise the next point will be filtered out even if it 
			// shouldn't be. Took me a while to find this bug. 
			// CoreyN 2004-08-20.
			if (nearf(m_ptA, m_ptB))
			{
				m_ptB = m_ptC;
				m_sizeBA.Width = m_ptA.X - m_ptB.X;
				m_sizeBA.Height = m_ptA.Y - m_ptB.Y;
				
				// recalculate length of vector BA (always positive)
				m_fLengthBA = sqrtf(powf(m_sizeBA.Width, 2.0f) + powf(m_sizeBA.Height, 2.0f));
			}
			else
			{
				m_ptB = m_ptC;
			}
			
		}
		else
		{
			// Not near collinear, add point B. B becomes A, C becomes B
			OutputPoint(m_ptB.X, m_ptB.Y, OUTPUT_TYPE_MOVE);
			m_ptsOut++;
			
			m_ptA = m_ptB;
			m_ptB = m_ptC;			
			m_sizeBA.Width = -m_sizeBC.Width;
			m_sizeBA.Height = -m_sizeBC.Height;
			m_fLengthBA = m_fLengthBC;
		}
		
	}
	
}

void CCollinearFilter::EndFilter(float x, float y)
{
	
	if (!m_isEnabled)
	{
		IPointFilter::EndFilter(x, y);
		return;
	}
	
	MoveFilter(x, y);
	OutputPoint(x, y, OUTPUT_TYPE_END);
	m_ptsOut++;
}
