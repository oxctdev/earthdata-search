import { pick } from 'lodash'

import { buildParams } from '../util/cmr/buildParams'
import { determineEarthdataEnvironment } from '../util/determineEarthdataEnvironment'
import { doSearchRequest } from '../util/cmr/doSearchRequest'
import { getApplicationConfig } from '../../../sharedUtils/config'
import { getJwtToken } from '../util/getJwtToken'
import { parseError } from '../../../sharedUtils/parseError'

/**
 * Perform an authenticated CMR Granule search
 * @param {Object} event Details about the HTTP request that it received
 */
const cmrGranuleSearch = async (event) => {
  const { body, headers } = event

  const { defaultResponseHeaders } = getApplicationConfig()

  const { requestId } = JSON.parse(body)

  // The 'Accept' header contains the UMM version
  const providedHeaders = pick(headers, ['Accept'])

  const earthdataEnvironment = determineEarthdataEnvironment(headers)

  // Whitelist parameters supplied by the request
  const permittedCmrKeys = [
    'concept_id',
    'bounding_box',
    'circle',
    'browse_only',
    'cloud_cover',
    'day_night_flag',
    'echo_collection_id',
    'equator_crossing_date',
    'equator_crossing_longitude',
    'exclude',
    'line',
    'online_only',
    'options',
    'orbit_number',
    'page_num',
    'page_size',
    'point',
    'polygon',
    'readable_granule_name',
    'sort_key',
    'temporal',
    'two_d_coordinate_system'
  ]

  const nonIndexedKeys = [
    'bounding_box',
    'circle',
    'concept_id',
    'exclude',
    'line',
    'point',
    'polygon',
    'readable_granule_name',
    'sort_key'
  ]

  try {
    console.log('CMR Granule Search')
    return doSearchRequest({
      jwtToken: getJwtToken(event),
      path: '/search/granules.json',
      params: buildParams({
        body,
        permittedCmrKeys,
        nonIndexedKeys
      }),
      providedHeaders,
      requestId,
      earthdataEnvironment
    })
  } catch (e) {
    return {
      isBase64Encoded: false,
      headers: defaultResponseHeaders,
      ...parseError(e)
    }
  }
}

export default cmrGranuleSearch
